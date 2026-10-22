# Surrogate-Assisted Process Optimisation for PFOA Capture

This repository contains the computational workflow for the modelling, surrogate training, and process optimisation of fixed-bed adsorption of PFOA from wastewater streams. The project integrates finite element simulations with machine learning to optimise the process capture cost ($/kg).

## Versions

*   **version1.0:** Fixed-bed adsorption using granular activated carbon (GAC).
*   **version2.0:** Fixed-bed adsorption for any material following the Langmuir isotherm. The material parameters and sorbent cost are included as model inputs, so different adsorbents can be evaluated and compared on capture cost.

## Governing Equations

Mass balance in the bulk liquid phase along the column:

$$
\frac{\partial C}{\partial t} = D_L \frac{\partial^2 C}{\partial z^2} - v \frac{\partial C}{\partial z} - \frac{1-\varepsilon}{\varepsilon} \rho_s \frac{\partial q}{\partial t}
$$

Solid phase balance (linear driving force model):

$$
\frac{\partial q}{\partial t} = k_{LDF} \left( q^{*} - q \right)
$$

with the Langmuir isotherm for the equilibrium loading, $q^{*} = \dfrac{q_m K_L C}{1 + K_L C}$.

## Project Structure

Both versions follow the same file structure.

```
.
├── version1.0/
│   ├── Adsorption_Model/
│   ├── ANN_Training/
│   └── Process_Optimisation/
├── version2.0/
│   ├── Adsorption_Model/
│   ├── ANN_Training/
│   └── Process_Optimisation/
├── LICENSE
└── README.md
```

*   **`Adsorption_Model/`**
    *   Contains the COMSOL Multiphysics models coupled with MATLAB LiveLink.
    *   **Sampling Approach:** Utilises Latin Hypercube Sampling (LHS) to generate a design of experiments across the target parameter space. This provides a well-distributed and unbiased dataset from the physics-based simulations for surrogate training.
*   **`ANN_Training/`**
    *   Contains the data processing and Artificial Neural Network (ANN) training scripts.
    *   Uses TensorFlow to train a surrogate model based on the LHS data generated in the first module.
*   **`Process_Optimisation/`**
    *   Contains the mathematical optimisation problem formulation using Pyomo.
    *   Utilises the Optimization and Machine Learning Toolkit (OMLT) to embed the trained TensorFlow ANN into the optimisation problem constraints.

## Variables

### Inputs

| Variable | Description | Units |
|---|---|---|
| `capacity` | Treatment capacity (flow rate) | m³/h |
| `diameter` | Column diameter | m |
| `column_height` | Column height | m |
| `porosity` | Bed porosity | - |
| `ads_time` | Adsorption time | days |
| `C_o` | Influent PFOA concentration | ppb |
| `rho_s` | Sorbent density | kg/m³ |
| `dp` | Particle diameter | m |
| `qm1` | Langmuir maximum adsorption capacity | mol/kg |
| `kl1` | Langmuir constant | m³/mol |
| `sorbent_cost_per_kg` | Sorbent cost per kg | $/kg |

### Outputs

| Variable | Description | Units |
|---|---|---|
| `total_LCP` | Total levelised cost of PFOA capture | $/kg PFOA |
| `emissions` | Process GHG emissions | kg CO₂-eq/kg PFOA |
| `PFAS_eff` | Effluent PFOA concentration | ppt |

In version1.0, the material properties are fixed to GAC and the treatment capacity is limited to a maximum of 120 m³/h. In version2.0, the material properties are model inputs and the treatment capacity extends up to 5000 m³/h.

## Prerequisites and Dependencies

To execute the full pipeline, you require the following software, solvers, and libraries:

### Core Software & Solvers
*   **MATLAB**
*   **COMSOL Multiphysics** (with the LiveLink for MATLAB module)
*   **Optimisation Solvers:**
    *   **Commercial:** BARON, CPLEX
    *   **Open-Source:** CBC, IPOPT

### Python Libraries
*   `tensorflow` (for ANN surrogate training)
*   `pyomo` (for process optimisation formulation)
*   `omlt` (for embedding the surrogate model)
*   `numpy` (for numerical operations)
*   `pandas` (for data handling)

## Licence and Usage Requirements

The code and scripts in this repository are provided under the **BSD 3-Clause Licence** (see the `LICENSE` file).

**Important Note on Dependencies:**
While the code provided here is open-source, executing the complete workflow requires valid commercial licences for the following proprietary software and solvers:
*   COMSOL Multiphysics & LiveLink for MATLAB
*   MATLAB
*   BARON
*   CPLEX

The CBC and IPOPT solvers, as well as the listed Python libraries, are open-source and freely available.

---
*Author: Hubert Treve (huberttreve@ufl.edu)*