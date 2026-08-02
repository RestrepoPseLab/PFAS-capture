# Surrogate-Assisted Process Optimisation for PFOA Capture

This repository contains the computational workflow for the modelling, surrogate training, and process optimisation of fixed-bed adsorption (GAC) of PFOA from wastewater streams. The project integrates engineering simulations with machine learning to optimise the process capture cost ($/kg).

## Project Structure

This repository is divided into three main modules:

*   **`1_Adsorption_Model/`**
    *   Contains the COMSOL Multiphysics models coupled with MATLAB LiveLink. 
    *   **Sampling Approach:** Utilises Latin Hypercube Sampling (LHS) to generate a design of experiments across the target parameter space. This provides a well-distributed and unbiased dataset from the physics-based simulations for surrogate training.
*   **`2_ANN_Training/`**
    *   Contains the data processing and Artificial Neural Network (ANN) training scripts. 
    *   Uses TensorFlow to train a surrogate model based on the LHS data generated in the first module. 
*   **`3_Process_Optimisation/`**
    *   Contains the mathematical optimisation problem formulation using Pyomo. 
    *   Utilises the Optimization and Machine Learning Toolkit (OMLT) to embed the trained TensorFlow ANN into the optimisation problem constraints.

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