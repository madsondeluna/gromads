#!/bin/bash

pdb2gmx_mpi -f PDef_Me.pdb -o PDef_Me_processed.gro -water spce -ignh <<EOF
13
EOF
editconf_mpi -f PDef_Me_processed.gro -o PDef_Me_newbox.gro -c -d 1.0 -bt cubic

genbox_mpi -cp PDef_Me_newbox.gro -cs spc216.gro -o PDef_Me_solv.gro -p topol.top

grompp_mpi -f ions.mdp -c PDef_Me_solv.gro -p topol.top -o ions.tpr

genion_mpi -s ions.tpr -o PDef_Me_solv_ions.gro -p topol.top -neutral -conc 0.15 -pname NA -nname CL <<EOF
13
EOF

grompp_mpi -f minim.mdp -c PDef_Me_solv_ions.gro -p topol.top -o em.tpr

mdrun_mpi -v -deffnm em -s em.tpr

g_energy_mpi -f em.edr -o potential.xvg <<EOF
10 0
EOF

grompp_mpi -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr

mdrun_mpi -deffnm nvt -v -s nvt.tpr

g_energy_mpi -f nvt.edr -o temperature.xvg <<EOF
15 0
EOF

grompp_mpi -f npt.mdp -c nvt.gro -t nvt.cpt -p topol.top -o npt.tpr

mdrun_mpi -deffnm npt -v -s npt.tpr

g_energy_mpi -f nvt.edr -o pressure.xvg <<EOF
17 0
EOF

grompp_mpi -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_0_1.tpr -maxwarn 5

#Rodar a dinâmica
#mdrun_mpi -deffnm md_0_1 -v -cpi checkpoint.cpt -pin on -resethway &