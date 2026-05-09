# NMOS Simulation using DevSim

This folder contains the complete simulation setup for an NMOS device using DevSim.

## Setup Instructions (Windows)

1. Open a Command Prompt or PowerShell in this folder (`C:\Users\tazwa\Documents\NMOS`).
2. Create a virtual environment to stay organized:
   `python -m venv .venv`
3. Activate the virtual environment:
   `.venv\Scripts\activate`
4. Install the required libraries:
   `pip install devsim numpy matplotlib`

## Running the Simulation

Run the main simulation script:
`python nmos_sim.py`

This will perform the required DC Sweeps, extract the device parameters (Vth, SS, DIBL, Transconductance, Leakage Current, Oxide Breakdown Limits), and generate the IDS vs VDS and Transfer Characteristics plots.

Results will be saved in `nmos_results.json` and as PNG plots in this directory.
