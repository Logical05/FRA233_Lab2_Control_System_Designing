clear
addpath("D:\University\Control\LAB\FRA233_Lab2_Control_System_Designing")
run("Lab2_params_student.m")

diff = tf([1, 0], 1);
plant_theta = plant * tf(1, [1, 0]);

controlSystemDesigner("Template.mat");