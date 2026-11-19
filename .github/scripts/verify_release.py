import argparse
import hashlib
import io
import plistlib
import struct
import tarfile
from pathlib import Path


def check_binary(data, project):
    magic, count = struct.unpack_from(">II", data)
    assert (magic, count) == (0xCAFEBABE, 2), "Expected arm64 and arm64e fat dylib"
    architectures = set()
    for index in range(count):
        cpu, subtype, offset, size, alignment = struct.unpack_from(">IIIII", data, 8 + 20 * index)
        architectures.add((cpu, subtype & 0xFFFFFF))
        image = data[offset:offset + size]
        assert struct.unpack_from("<I", image)[0] == 0xFEEDFACF
        commands = struct.unpack_from("<I", image, 16)[0]
        cursor = 32
        signed = False
        for _ in range(commands):
            command, length = struct.unpack_from("<II", image, cursor)
            if command in (0xC, 0xD, 0x80000018, 0x8000001F):
                start = cursor + struct.unpack_from("<I", image, cursor + 8)[0]
                name = image[start:cursor + length].split(b"\0", 1)[0].decode()
                if command == 0xD:
                    assert name == f"@rpath/{project}.dylib", name
                else:
                    assert name.startswith(("/System/Library/", "/usr/lib/")), name
                    assert not any(word in name.lower() for word in ("substrate", "hooker", "roothide")), name
            if command == 0x1D:
                signed = struct.unpack_from("<I", image, cursor + 12)[0] > 0
            cursor += length
        assert signed, "Missing code signature"
    assert architectures == {(0x0100000C, 0), (0x0100000C, 2)}


def read_deb(path):
    members = {}
    with path.open("rb") as archive:
        assert archive.read(8) == b"!<arch>\n"
        while header := archive.read(60):
            assert len(header) == 60 and header[58:] == b"`\n"
            size = int(header[48:58])
            members[header[:16].decode().strip().rstrip("/")] = archive.read(size)
            if size % 2:
                archive.read(1)
    return members


parser = argparse.ArgumentParser()
parser.add_argument("folder", type=Path)
parser.add_argument("--binary-only", action="store_true")
args = parser.parse_args()
metadata = dict(line.split(": ", 1) for line in Path("control").read_text().splitlines() if ": " in line)
project, version = metadata["Name"], metadata["Version"]
binary = args.folder / f"{project}.dylib"
data = binary.read_bytes()
check_binary(data, project)
print(project, version, "arm64 + arm64e", hashlib.sha256(data).hexdigest())
if args.binary_only:
    raise SystemExit(0)

expected_files = {binary.name}
for architecture in ("iphoneos-arm", "iphoneos-arm64", "iphoneos-arm64e"):
    path = args.folder / f"{metadata['Package']}_{version}_{architecture}.deb"
    expected_files.add(path.name)
    members = read_deb(path)
    with tarfile.open(fileobj=io.BytesIO(next(v for k, v in members.items() if k.startswith("control.tar")))) as archive:
        control = archive.extractfile(next(m for m in archive if Path(m.name).name == "control")).read().decode()
        fields = dict(line.split(": ", 1) for line in control.splitlines() if ": " in line)
        assert fields["Package"] == metadata["Package"] and fields["Version"] == version
        assert fields["Architecture"] == architecture
        assert fields["Author"] == fields["Maintainer"] == "cc"
    prefix = "var/jb/" if architecture == "iphoneos-arm64" else ""
    directory = prefix + "Library/MobileSubstrate/DynamicLibraries/"
    with tarfile.open(fileobj=io.BytesIO(next(v for k, v in members.items() if k.startswith("data.tar")))) as archive:
        files = {m.name.removeprefix("./"): m for m in archive.getmembers() if m.isfile()}
        assert set(files) == {directory + project + ".dylib", directory + project + ".plist"}
        assert archive.extractfile(files[directory + project + ".dylib"]).read() == data, "Binary differs between environments"
        filter_data = archive.extractfile(files[directory + project + ".plist"]).read()
        try:
            bundles = plistlib.loads(filter_data)["Filter"]["Bundles"]
            assert set(bundles) == {"com.tencent.xin", "com.tencent.qy.xin"}
        except plistlib.InvalidFileException:
            assert filter_data == Path(project + ".plist").read_bytes()
    print(path.name, "verified")
assert {p.name for p in args.folder.iterdir() if p.is_file()} == expected_files
print("Four Release assets verified, each package contains the same signed dylib.")
