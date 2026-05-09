import devsim
import nmos_meshing
import numpy as np
import json

device = "mymos"
silicon_regions = ("gate", "bulk")
oxide_regions = ("oxide",)
regions = ("gate", "bulk", "oxide")
interfaces = ("bulk_oxide", "gate_oxide")

from devsim.python_packages.simple_physics import (
    GetContactBiasName,
    SetOxideParameters,
    SetSiliconParameters,
    CreateSiliconPotentialOnly,
    CreateSiliconPotentialOnlyContact,
    CreateSiliconDriftDiffusion,
    CreateSiliconDriftDiffusionAtContact,
    CreateOxidePotentialOnly,
    CreateSiliconOxideInterface,
)
from devsim.python_packages.ramp import rampbias, printAllCurrents
from devsim.python_packages.Klaassen import (
    Set_Mobility_Parameters,
    Klaassen_Mobility,
    Philips_VelocitySaturation,
    Philips_Surface_Mobility,
)
from devsim.python_packages.mos_physics import (
    CreateElementElectronContinuityEquation,
    CreateElementContactElectronContinuityEquation,
    CreateNormalElectricFieldFromCurrentFlow,
    CreateElementElectronCurrent2d,
)
from devsim.python_packages.model_create import CreateSolution, CreateElementModel2d

for i in regions:
    CreateSolution(device, i, "Potential")

for i in silicon_regions:
    SetSiliconParameters(device, i, 300)
    CreateSiliconPotentialOnly(device, i)

for i in oxide_regions:
    SetOxideParameters(device, i, 300)
    CreateOxidePotentialOnly(device, i, "log_damp")

### Set up contacts
contacts = devsim.get_contact_list(device=device)
for i in contacts:
    tmp = devsim.get_region_list(device=device, contact=i)
    r = tmp[0]
    print("%s %s" % (r, i))
    CreateSiliconPotentialOnlyContact(device, r, i)
    devsim.set_parameter(device=device, name=GetContactBiasName(i), value=0.0)

for i in interfaces:
    CreateSiliconOxideInterface(device, i)

devsim.solve(type="dc", absolute_error=1.0e-13, relative_error=1e-12, maximum_iterations=30)
devsim.solve(type="dc", absolute_error=1.0e-13, relative_error=1e-12, maximum_iterations=30)

for i in silicon_regions:
    CreateSolution(device, i, "Electrons")
    CreateSolution(device, i, "Holes")
    devsim.set_node_values(
        device=device, region=i, name="Electrons", init_from="IntrinsicElectrons"
    )
    devsim.set_node_values(device=device, region=i, name="Holes", init_from="IntrinsicHoles")

    Set_Mobility_Parameters(device, i)
    Klaassen_Mobility(device, i)
    # use bulk Klaassen mobility
    CreateSiliconDriftDiffusion(device, i, "mu_bulk_e", "mu_bulk_h")

for c in contacts:
    tmp = devsim.get_region_list(device=device, contact=c)
    r = tmp[0]
    CreateSiliconDriftDiffusionAtContact(device, r, c)

for r in silicon_regions:
    devsim.node_model(
        device=device, region=r, name="logElectrons", equation="log(Electrons)/log(10)"
    )
    CreateNormalElectricFieldFromCurrentFlow(device, r, "ElectronCurrent")
    CreateNormalElectricFieldFromCurrentFlow(device, r, "HoleCurrent")
    Philips_Surface_Mobility(
        device, r, "Enormal_ElectronCurrent", "Enormal_HoleCurrent"
    )
    Philips_VelocitySaturation(
        device, r, "mu_vsat_e", "mu_e_0", "Eparallel_ElectronCurrent", "vsat_e"
    )
    CreateElementModel2d(device, r, "mu_ratio", "mu_vsat_e/mu_bulk_e")
    CreateElementModel2d(device, r, "mu_surf_ratio", "mu_e_0/mu_bulk_e")
    CreateElementModel2d(
        device, r, "epar_ratio", "abs(Eparallel_ElectronCurrent/ElectricField_mag)"
    )
    CreateElementElectronCurrent2d(device, r, "ElementElectronCurrent", "mu_vsat_e")
    CreateElementModel2d(
        device,
        r,
        "magElementElectronCurrent",
        "log(abs(ElementElectronCurrent)+1e-10)/log(10)",
    )
    devsim.vector_element_model(
        device=device, region=r, element_model="ElementElectronCurrent"
    )
    CreateElementElectronContinuityEquation(device, r, "ElementElectronCurrent")

for contact in ("body", "drain", "source"):
    CreateElementContactElectronContinuityEquation(
        device, contact, "ElementElectronCurrent"
    )

devsim.solve(type="dc", absolute_error=1.0e30, relative_error=1e-10, maximum_iterations=100)

print("Starting sweep")

def extract_currents(device, contact):
    return devsim.get_contact_current(device=device, contact=contact, equation="ElectronContinuityEquation")

# Set base bias
devsim.set_parameter(device=device, name=GetContactBiasName("source"), value=0.0)
devsim.set_parameter(device=device, name=GetContactBiasName("body"), value=0.0)

vgs_sweep = np.arange(-0.5, 1.51, 0.2)
id_vgs_lin = []
id_vgs_sat = []

print("Running Id-Vgs at Vds=0.05V")
devsim.set_parameter(device=device, name=GetContactBiasName("drain"), value=0.0)
devsim.solve(type="dc", absolute_error=1.0e30, relative_error=1e-10, maximum_iterations=100)
rampbias(device, "drain", 0.05, 0.05, 0.001, 100, 1e-8, 1e30, printAllCurrents)

for vgs in vgs_sweep:
    rampbias(device, "gate", vgs, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
    ids = extract_currents(device, "drain")
    id_vgs_lin.append(ids)

print("Running Id-Vgs at Vds=1.0V")
rampbias(device, "gate", 0.0, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
rampbias(device, "drain", 1.0, 0.1, 0.001, 100, 1e-8, 1e30, printAllCurrents)

for vgs in vgs_sweep:
    rampbias(device, "gate", vgs, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
    ids = extract_currents(device, "drain")
    id_vgs_sat.append(ids)

vds_sweep = np.arange(0.0, 1.51, 0.2)
id_vds = {}

rampbias(device, "gate", 0.0, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
rampbias(device, "drain", 0.0, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)

vgs_list = [0.5, 1.0, 1.5]
for vgs in vgs_list:
    print(f"Running Id-Vds at Vgs={vgs}V")
    rampbias(device, "drain", 0.0, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
    rampbias(device, "gate", vgs, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)

    id_vds[vgs] = []
    for vds in vds_sweep:
        rampbias(device, "drain", vds, 0.2, 0.001, 100, 1e-8, 1e30, printAllCurrents)
        ids = extract_currents(device, "drain")
        id_vds[vgs].append(ids)

def get_vth_gm(vgs_vals, id_vals):
    id_vals = np.abs(id_vals)
    gm = np.gradient(id_vals, vgs_vals)
    max_gm_idx = np.argmax(gm)
    vth = vgs_vals[max_gm_idx] - id_vals[max_gm_idx] / gm[max_gm_idx]
    return vth, gm[max_gm_idx]

vth_lin, _ = get_vth_gm(vgs_sweep, id_vgs_lin)
vth_sat, gm_max_sat = get_vth_gm(vgs_sweep, id_vgs_sat)
dibl = (vth_lin - vth_sat) / (1.0 - 0.05) if (1.0 - 0.05) != 0 else 0

def get_ss(vgs_vals, id_vals, vth):
    id_vals = np.abs(id_vals)
    mask = (vgs_vals < vth) & (id_vals > 1e-14)
    if not np.any(mask):
        return float('nan')
    vgs_sub = vgs_vals[mask]
    log_id_sub = np.log10(id_vals[mask])

    if len(vgs_sub) < 2:
        return float('nan')

    slopes = np.gradient(log_id_sub, vgs_sub)
    max_slope = np.max(slopes)
    ss = 1.0 / max_slope * 1000
    return ss

ss_lin = get_ss(vgs_sweep, id_vgs_lin, vth_lin)

leakage_idx = np.argmin(np.abs(vgs_sweep - 0.0))
leakage_current = id_vgs_sat[leakage_idx] if leakage_idx < len(id_vgs_sat) else 0

tox = 1e-5
E_max = 1.5 / tox
breakdown_limit = E_max / 1e7

results = {
    "Transfer Characteristics": {
        "Vgs": list(vgs_sweep),
        "Id_lin_Vds_0_05": list(id_vgs_lin),
        "Id_sat_Vds_1_0": list(id_vgs_sat)
    },
    "Output Characteristics": {
        "Vds": list(vds_sweep),
        "Id_Vgs_0_5": list(id_vds[0.5]),
        "Id_Vgs_1_0": list(id_vds[1.0]),
        "Id_Vgs_1_5": list(id_vds[1.5])
    },
    "Device Parameters": {
        "Vth_lin": vth_lin,
        "Vth_sat": vth_sat,
        "DIBL (V/V)": dibl,
        "SS (mV/dec)": ss_lin,
        "Transconductance_max (S/um)": gm_max_sat,
        "Leakage_Current_Vgs_0 (A/um)": leakage_current,
        "Max_Oxide_Field_MV_cm": E_max / 1e6
    }
}

with open("nmos_results.json", "w") as f:
    json.dump(results, f, indent=4)
