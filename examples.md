---
layout: default
title: "DynaMoDE MATLAB Examples — Dynamic Mode Decomposition and Koopman Analysis"
description: "Explore DynaMoDE methods and MATLAB examples for DMD modes, modal reconstruction, prediction, rank truncation, synthetic fields, video analysis and thermal experiments."
permalink: /examples/
---

# DynaMoDE: MATLAB examples and numerical methods

**DynaMoDE — Dynamic Mode Decomposition Engine** is a modular MATLAB research framework for Dynamic Mode Decomposition (DMD), modal analysis, spatiotemporal reconstruction and prediction of dynamical data. It also supports analysis motivated by Koopman operator theory.

[Homepage](https://dmdcode.org/) · [Source-code repository](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0)

## Available methods and examples

### DMD modes and singular values

[**DMD_Modes**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/DMD_Modes) — DMD modes, singular-value analysis, and corresponding plots; includes `Dmd_modes.m`, `Dmd_sv.m`, and `dmd.m`.

### Spatiotemporal reconstruction

[**DMD_Reconstruction**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/DMD_Reconstruction) — MATLAB scripts for preparing snapshot data, reconstructing dynamic fields, and plotting reconstructed results.

### DMD prediction

[**DMD_Prediction**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/DMD_Prediction) — Prediction routines using computed DMD representations, including `Dmd_predict.m`.

### Similarity analysis and rank truncation

[**Similarity_Analysis**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/Similarity_Analysis) — Numerical analysis and plots for truncation, with `Sim_trunc.m` and `Plot_sim_trunc.m`.

### Synthetic dynamic fields

[**Dynamic_Field_Generator**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/Dynamic_Field_Generator) — Generation of dynamic and static test fields, including Ackley, Griewank, Rastrigin, and Schaffer benchmark functions.

### Bird-video DMD analysis

[**Example-BirdVideo**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/Example-BirdVideo) — Video examples with `MainVideoAnalysisDMD.m` and `MainVideoAnalysisDMD_Color.m`.

### Rastrigin-field DMD analysis

[**Example-RastriginField**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/Example-RastriginField) — Synthetic Rastrigin-field analysis with `RastriginFieldDMD.m` and visualization scripts.

### Thermal experiments

[**ThermalExperiment**](https://github.com/americocunhajr/DynaMoDE/tree/master/DynaMoDE-1.0/ThermalExperiment) — Reconstruction workflows with `DMD_Reconstruction_Conv.m` and `DMD_Reconstruction_Images.m`.

## Getting started

Clone [DynaMoDE](https://github.com/americocunhajr/DynaMoDE) and open the `DynaMoDE-1.0/` directory in MATLAB. Choose the method or example folder relevant to your application. Several folders include their own `README.txt` with workflow-specific notes. Check individual scripts for data-file requirements and configuration parameters.

## Frequently asked questions

### What is Dynamic Mode Decomposition?

DMD is a data-driven numerical method that extracts spatial modes and associated temporal behavior from sequential snapshots of a dynamical system.

### How does DMD relate to Koopman operator theory?

DMD produces a finite-dimensional approximation that is often interpreted in connection with Koopman operator spectral analysis.

### Can DynaMoDE analyze experimental data?

The repository contains thermal experiment reconstruction scripts and video-analysis examples, alongside synthetic benchmarks.

### Which programming language is required?

The provided method and example scripts are written in MATLAB.

## Research citation

The [DynaMoDE homepage](https://dmdcode.org/#citing-dynamode) contains its accompanying 2026 book-chapter references and BibTeX entry.
