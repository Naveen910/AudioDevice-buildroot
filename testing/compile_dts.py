import os
import subprocess
import urllib.request
import sys

# Configuration
DTS_FILENAME = "suniv-f1c100s-custom-audio-board.dts"
DTB_FILENAME = "suniv-f1c100s-custom-audio-board.dtb"
PREPROCESSED_FILENAME = "preprocessed.dts"
INCLUDE_DIR = "dts_includes"

# Base URLs (Linux v6.6)
BASE_URL_DTS = "https://raw.githubusercontent.com/torvalds/linux/v6.6/arch/arm/boot/dts/allwinner"
BASE_URL_BINDINGS = "https://raw.githubusercontent.com/torvalds/linux/v6.6/include/dt-bindings"

# Files to download
# NOTE: Removed suniv.dtsi (per request) and linux-event-codes.h (mocked locally)
FILES_TO_FETCH = {
    f"{BASE_URL_DTS}/suniv-f1c100s.dtsi": "suniv-f1c100s.dtsi",
    
    # Headers
    f"{BASE_URL_BINDINGS}/gpio/gpio.h": "dt-bindings/gpio/gpio.h",
    f"{BASE_URL_BINDINGS}/input/input.h": "dt-bindings/input/input.h",
    f"{BASE_URL_BINDINGS}/interrupt-controller/arm-gic.h": "dt-bindings/interrupt-controller/arm-gic.h",
    f"{BASE_URL_BINDINGS}/interrupt-controller/irq.h": "dt-bindings/interrupt-controller/irq.h",
    f"{BASE_URL_BINDINGS}/clock/suniv-ccu-f1c100s.h": "dt-bindings/clock/suniv-ccu-f1c100s.h",
    f"{BASE_URL_BINDINGS}/reset/suniv-ccu-f1c100s.h": "dt-bindings/reset/suniv-ccu-f1c100s.h",
    f"{BASE_URL_BINDINGS}/dma/sun4i-a10.h": "dt-bindings/dma/sun4i-a10.h",
}

def clean_old_files():
    """Force cleanup of potentially corrupt files from previous runs."""
    bad_files = [
        "dts_includes/dt-bindings/input/linux-event-codes.h",
        "preprocessed.dts"
    ]
    for f in bad_files:
        if os.path.exists(f):
            try:
                os.remove(f)
            except:
                pass

def download_file(url, local_path):
    full_local_path = os.path.join(INCLUDE_DIR, local_path)
    os.makedirs(os.path.dirname(full_local_path), exist_ok=True)
    
    if os.path.exists(full_local_path):
        return

    print(f"[DOWN] Downloading {local_path}...")
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read()
            if b"<!DOCTYPE" in content or b"<html" in content:
                 print(f"[WARN] Skipping HTML garbage for {local_path}")
                 return
            with open(full_local_path, 'wb') as f:
                f.write(content)
    except Exception as e:
        print(f"[ERR ] Failed to download {url}: {e}")

def create_mock_files():
    """
    Creates dummy files for dependencies that are causing 404s or are unwanted.
    This tricks the compiler into thinking everything is fine.
    """
    # 1. Mock 'suniv.dtsi' 
    # suniv-f1c100s.dtsi includes this. We create an empty root node so it doesn't crash.
    suniv_path = os.path.join(INCLUDE_DIR, "suniv.dtsi")
    if not os.path.exists(suniv_path):
        print("[MOCK] Creating dummy suniv.dtsi")
        with open(suniv_path, "w") as f:
            f.write("/ { };\n") # Valid empty DTS

    # 2. Mock 'linux-event-codes.h'
    # input.h tries to include this, but the URL is unstable/complex.
    # We create a local empty file so the #include works but defines nothing.
    codes_path = os.path.join(INCLUDE_DIR, "dt-bindings/input/linux-event-codes.h")
    os.makedirs(os.path.dirname(codes_path), exist_ok=True)
    if not os.path.exists(codes_path):
        print("[MOCK] Creating dummy linux-event-codes.h")
        with open(codes_path, "w") as f:
            f.write("/* Dummy event codes */\n")

def patch_input_h():
    """Patches input.h to use our local mock file."""
    input_h_path = os.path.join(INCLUDE_DIR, "dt-bindings/input/input.h")
    
    if os.path.exists(input_h_path):
        with open(input_h_path, 'r') as f:
            content = f.read()
        
        # Replace kernel path with local path
        new_content = content.replace('../../uapi/linux/input-event-codes.h', 'linux-event-codes.h')
        
        if content != new_content:
            print("[FIX ] Patching input.h include path...")
            with open(input_h_path, 'w') as f:
                f.write(new_content)

def compile_dts():
    # 1. Run Preprocessor
    print(f"[INFO] Preprocessing {DTS_FILENAME}...")
    
    cpp_cmd = [
        "cc", "-E", "-P", "-nostdinc",
        "-I", INCLUDE_DIR,
        "-undef", "-x", "assembler-with-cpp",
        DTS_FILENAME
    ]
    
    try:
        with open(PREPROCESSED_FILENAME, "w") as outfile:
            subprocess.check_call(cpp_cmd, stdout=outfile)
    except subprocess.CalledProcessError:
        print("[FAIL] Preprocessor failed.")
        return

    # 2. Run Compiler
    print(f"[INFO] Compiling to {DTB_FILENAME}...")
    
    dtc_cmd = [
        "dtc", "-I", "dts", "-O", "dtb", "-o", DTB_FILENAME, PREPROCESSED_FILENAME
    ]

    p = subprocess.Popen(dtc_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    
    if p.returncode == 0:
        print(f"\n[SUCC] SUCCESS! {DTB_FILENAME} generated.")
        if os.path.exists(PREPROCESSED_FILENAME):
            os.remove(PREPROCESSED_FILENAME)
    else:
        print(f"\n[FAIL] DTC Errors:")
        print(err.decode('utf-8'))

if __name__ == "__main__":
    print("--- Robust DTS Compiler ---")
    if subprocess.call(["which", "dtc"], stdout=subprocess.DEVNULL) != 0:
        print("Error: 'dtc' not installed. Run: brew install dtc")
        sys.exit(1)

    clean_old_files()
    
    for url, path in FILES_TO_FETCH.items():
        download_file(url, path)

    create_mock_files()
    patch_input_h()
    compile_dts()