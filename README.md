

````markdown
# VSD-PD Codespace  
**OpenROAD + noVNC Cloud Environment**

This repository launches a **ready-to-use cloud Codespace** with OpenROAD tools, an XFCE desktop, and noVNC browser access — ideal for testing and learning VLSI flows.

---

## 🚀 Launch the Codespace

1. Click **Code → Codespaces → Create codespace on main**  
   ![Launch Codespace](images/1_launchCodeSpace.jpg)

2. Wait for the build to complete:  
   ![Codespace log](images/2_codespaceLog.jpg)  
   ![Codespace created](images/3_codepsaceCreated.jpg)

---

## 🧠 Run OpenROAD Flow Scripts

Inside the Codespace terminal (or the noVNC Desktop terminal) run:

```bash
cd ~/Desktop
git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
cd OpenROAD-flow-scripts/flow
make
````

If you hit a TCL error during the `make`, edit:

```bash
vim scripts/synth_stdcells.tcl
```

Comment the second `read_liberty` line:

```tcl
#read_liberty -overwrite -setattr liberty_cell \
#  -unit_delay -wb -ignore_miss_func -ignore_buses {*}$::env(LIB_FILES)
```

Then rerun:

```bash
make
```

When the flow finishes, you’ll see the summary log:
![Flow completes](images/8_makeCompletes.jpg)

---

## 🖥️ Access the GUI via noVNC

Go to the **PORTS** tab → click the 🌐 icon next to port **6080**
![Open noVNC](images/9_openVNC.jpg)
Connect to the browser-based desktop.
![VNC desktop](images/10_vnc_lite.jpg)

---

## ⚠️ Important Notice

This Codespace setup uses the official OpenROAD-flow-scripts from the OpenROAD Project.
While you are free to experiment, the repository here is provided **for testing and learning only**, and is **not an official distribution channel**.

For the canonical project, documentation and updates, visit:
👉 [OpenROAD Project’s official repo](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/)

```


