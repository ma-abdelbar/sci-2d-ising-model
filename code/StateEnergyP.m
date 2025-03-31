%   Author : Mohamed A. Abdelbar
%   Date   : 20/03/2018
%   Description : 
%   This is a function that calculates the Total Energy of the microstate
%   that the system is in according to the 2D Ising Model in with periodic
%   boundary conditions
%%
function [Es] = StateEnergyP (s,J,H)
%   Inputs:
%   s : Specifies the microstate for which the Energy is to be calculated.
%       It is a matrix with the same dimensions as the system.
%   J : Specifies the coupling constant for the Ising model.
%   H : Specifies the strength of the uniform external field component
%   directed either parallel or anti-parallel to the spin directions.
%   Output:
%   Es : Is the calculated Energy in Joules
%%
[n,m] = size(s);    %   Extract the dimensions of the system
E = 0;             
%   We must now perform a sum over all distinct nearest neighbour pairs
%   We first loop over all the lattice except for the bottom side.
for i = 1 : n-1
    for j = 1 : m
        %    We go over each lattice point and consider the nearest
        %    neighbour to the right and below.
        if j < m
            e = -J *(((s(i,j))*(s(i+1,j)))+((s(i,j))*(s(i,j+1)))) - H*(s(i,j));
            E = E + e;
        else
        % Here we take into account the right side of the lattice which
        % should wrap around to the left side of the lattice for the BCs
            e = -J *(((s(i,j))*(s(i+1,j)))+((s(i,j))*(s(i,1)))) - H*(s(i,j));
            E = E + e;
        end
    end
end
i = n;
%   Here we take into account the bottom side of the lattice. Which should
%   wrap around to the top in order to satisfy the periodic BCs.
for j = 1 : m-1
     e = -J *(((s(i,j))*(s(1,j)))+((s(i,j))*(s(i,j+1)))) - H*(s(i,j));
     E = E + e;
end
%   Finally we take into account the corner cell at the bottom right of the
%   lattice.
j = m;
e =  -J *(((s(i,j))*(s(1,j)))+((s(i,j))*(s(i,1)))) - H*(s(i,j));
E = E + e;
Es = E;
