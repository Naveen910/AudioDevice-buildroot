import subprocess
import sys
import os

DTB_FILENAME = "suniv-f1c100s-custom-audio-board.dtb"

def verify_dtb():
    print(f"--- Verifying {DTB_FILENAME} ---")
    
    if not os.path.exists(DTB_FILENAME):
        print(f"[FAIL] File not found: {DTB_FILENAME}")
        return

    # Decompile DTB back to text to inspect it
    try:
        # -I dtb: Input format is binary
        # -O dts: Output format is text
        result = subprocess.run(
            ["dtc", "-I", "dtb", "-O", "dts", DTB_FILENAME], 
            capture_output=True, 
            text=True
        )
        
        if result.returncode != 0:
            print("[FAIL] Could not decompile DTB. It might be corrupt.")
            print(result.stderr)
            return
            
        dts_content = result.stdout
        
        # Check for Critical Netlist Components
        checklist = {
            "MAX98357A (Amp)": "max98357a",
            "Si4703 (FM Radio)": "si470x",
            "I2S Controller (Audio Logic)": "i2s@1c22000",
            "I2S Pins (PD8/9/11)": "pins = \"PD8\", \"PD9\", \"PD11\"",
            "FM I2C Address (0x10)": "reg = <0x10>",
            "Sound Card": "simple-audio-card,name = \"F1C100s-MAX98357A\""
        }
        
        print("\nChecking for hardware components...")
        all_passed = True
        for name, signature in checklist.items():
            if signature in dts_content:
                print(f"[OK] Found: {name}")
            else:
                print(f"[MISSING] {name} - Not found in binary!")
                all_passed = False
                
        if all_passed:
            print("\n[SUCCESS] The DTB contains all your custom hardware definitions.")
        else:
            print("\n[WARNING] Some components are missing. Check your DTS file.")

    except FileNotFoundError:
        print("Error: 'dtc' command not found. Cannot verify.")

if __name__ == "__main__":
    verify_dtb()