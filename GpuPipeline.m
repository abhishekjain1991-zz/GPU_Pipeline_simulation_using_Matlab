
clear all;
close all;
%%%%%% USED LEFT HANDED CONVENTION  %%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% World transformation co-ordiantes%%%%%%%%%%%
Tx =  -30;
Ty =  -30;
Tz =  50;

Qx = deg2rad(0);   %rotation angle used for rotation along x-axis
Qy = deg2rad(90);  %rotation angle used for rotation along x-axis
Qz = deg2rad(0);   %rotation angle used for rotation along x-axis



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scaling factor scaling
Sx = 4;
Sy = 4;
Sz = 4;
%%%%%%%%%%%%%%%%%%% view transformation parameter%%%%%%%%
a = deg2rad(-20);  % field of view
r = 1;     % aspect ratio
n = -65;   % near plan;
f = -60;   % far plan

%%%%%%%%%%%%%%%%%% flags for setting parameters on/off for different stages in pipeline %%%%%%%%%%

rot   =   1;    % if set = 1 turn on the rotation stage
world_trans =   1;    % if set = 1 turn on the translation 
proj  =   1;    % for prospective projection
culon =   1;    % for  culling 
lighting = 1;   % for lighting
view_method =1; % for view transform
clipping =1;    % for clipping
zsort = 1;      % for zsorting


%%%%%%%%%%%%%%%%%   parameters for view transformation %%%%%%%%%%%%%%%
        cam_pos = [0 0 0];
        look_pt = [-30   -30     50];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% light position             %%%%%%%%%%%%%%%%%%%%%%%
 Light_pos = [0 -10 20];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%  emissive %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
         Cemis = [0.0 0.0 0.0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
 
%%%%%%%%%%%%%%%%%%%%%%%%%%    diffusion       %%%%%%%%%%%%%%%%%%%%%%%%
Mdiff =  [0.8, 0.7, 0.2];
Ldiff = [0.5 0.5 0.5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% ambient               %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mamb =  [0.8, 0.7, 0.2];
Lamb = [0.5 0.5 0.5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%    specular %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SMspec =     [0.8, 0.7, 0.2];
Lspec =     [0.5 0.5 0.5]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%         Translation & Rotation Matrix     %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



WT = [cos(Qx)*cos(Qy)     cos(Qx)*sin(Qy)*sin(Qz)-sin(Qx)*cos(Qz)   cos(Qx)*sin(Qy)*cos(Qz)+ sin(Qx)*sin(Qz)     Tx;
      sin(Qx)*cos(Qy)     sin(Qx)*sin(Qy)*sin(Qz)+cos(Qx)*cos(Qz)   sin(Qx)*sin(Qy)*cos(Qz)+ cos(Qx)*sin(Qz)     Ty;
        -sin(Qy)             cos(Qy)*sin(Qx)                           cos(Qy)*cos(Qz)                           Tz;
        0                       0                                            0                                    1      ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%         Scaling  matrix      %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   S  = [Sx 0 0 0 
         0 Sy 0 0
         0 0 Sz 0
         1 1 1  1] ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%         Projection   matrix      %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Tproj  =     [1/r*cot(a/2)     0              0               0  
                  0                cot(a/2)       0               0
                  0                0              f/(f-n)         1 
                  0                0             -(f*n)/(f-n)     0] ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




x = load('Shark.obj.txt');
set(0,'DefaultPatchEdgeColor','none');
[row col] = size(x);
X = [];
Y=  [];
Z = [];
for i = 1:row
    j =1; 
    
    A = [ x(i,j)   ;   x(i,j+3) ;  x(i,j+6)];
    B = [ x(i,j+1) ;  x(i,j+4)  ; x(i,j+7)];
    D = [ x(i,j+2) ;  x(i,j+5)  ; x(i,j+8)];  
    
%   patch(K,L,M,'FaceColor','interp');
 
    X = [X;A];
    Y = [Y;B];
    Z = [Z;D];
end  

  % translation  from object to word
  % combine to make on matrix
  C  = [X Y Z]; 
  C  = [C ones(row*3,1)]; 
  %figure
  %title('original object');
  for i = 1:3 : 3*row
  % E=  [  C(i,1)  ;   C(i+1,1)   ;     C(i+2,1)];
  % F = [  C(i,2)  ;   C(i+1,2)  ;     C(i+2,2)];
  % G = [  C(i,3)  ;   C(i+1,3)  ;    C(i+2,3)];  
  % patch(E,F,G, [rand(1) rand(1) rand(1)]);
  end 
  
  
C=(WT*C')';  %%%%%%%%%%% World Transformation   %%%%%%%%%%%%
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%         Lighting          %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if(lighting == 1)
% figure
% title('after lighting')
% set(0,'DefaultPatchEdgeColor','none'); 
% xlabel('x');
% ylabel('y');
% zlabel('z');
 
 Ccalc=[];
 Ctot=[];
Camb = Mamb.*Lamb; 
Diff = Mdiff.*Ldiff;
Spec = SMspec.*Lspec

   
for i = 1 : 3 : 3*row
 % Diffuse lighting  
 
      V1 = [(C(i,1)- C(i+1,1)) (C(i,2)- C(i+1,2)) (C(i,3)- C(i+1,3)) ];
      V2 = [(C(i,1)- C(i+2,1)) (C(i,2)-C(i+2,2)) (C(i,3)- C(i+2,3)) ];
      point = [ (C(i,1)+ C(i+1,1)+C(i+2,1)) (C(i,2)+C(i+1,2)+C(i+2,2))  (C(i,3)+C(i+1,3)+C(i+2,3))];
      point = point./3;
      light_vec = point-Light_pos;
      light_vec = light_vec/norm(light_vec);
      V3 = cross(V2,V1);
      V3 = V3./norm(V3);
      Cdiff = max(dot(light_vec,V3),0)*Diff;

% specular lighting 
   
       S =  10;
       V4 = [ (C(i,1)+ C(i+1,1)+C(i+2,1)) (C(i,2)+C(i+1,2)+C(i+2,2))  (C(i,3)+C(i+1,3)+C(i+1,3))];
       V4 =   V4./3;       
       E =   -(cam_pos - V4);       
       Light_vec = -(Light_pos - V4);
       H1 = (E + (Light_vec))/norm((E + (Light_vec)));
       
       Cspec = ((max(dot(V3,H1),0))^S)*Spec;
       
        Ccalc=(Cemis +Cspec + Cdiff + Camb);   
        for j = 1:3
         Ctot = [Ctot;Ccalc];
        end 
      
        % E  =  [  C(i,1)   ;   C(i+1,1) ;          C(i+2,1)];
        % F =   [  C(i,2)   ;   C(i+1,2)   ;        C(i+2,2)];
        % G =   [  C(i,3)   ;   C(i+1,3)   ;        C(i+2,3)] ;  
        % patch(E,F,G,[min(1,Ctot(i,1)) min(1,Ctot(i,2)) min(1,Ctot(i,3))]); 
         
      end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Lighting  END           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% view transform  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(view_method ==1)
        %figure
        %title('after view transform');
        %set(0,'DefaultPatchEdgeColor','none'); 
        
        n_vec = cam_pos-look_pt;
        n_vec = n_vec./norm(n_vec);
        u_vec = cross([0 1 0],n_vec);
        u_vec = u_vec/norm(u_vec);
        
        v_vec = cross(n_vec,u_vec);
        v_vec = v_vec/norm(v_vec);
 Tmet = [u_vec(1,1)                v_vec(1,1)                      n_vec(1,1)                   0 
         u_vec(1,2)                v_vec(1,2)                      n_vec(1,2)                   0
         u_vec(1,3)                v_vec(1,3)                      n_vec(1,3)                   0 
         -(dot(u_vec,cam_pos))    -(dot(v_vec,cam_pos))           -(dot(n_vec,cam_pos))         1] ;
        
        for i = 1 : 3*row
        C(i,:)  =  C (i,:)* Tmet;     %View Transformation%
        end 
        for i = 1:3 : 3*row 
        E=  [  C(i,1)  ;   C(i+1,1)   ;     C(i+2,1)];
        F = [  C(i,2)  ;   C(i+1,2)  ;     C(i+2,2)];
        G = [  C(i,3)  ;   C(i+1,3)  ;    C(i+2,3)];  
        %if( (n<G(1,1) && G(1,1)< f )&& (n<G(2,1) && G(1,1)< f ) &&(n<G(3,1) && G(1,1)< f ))
        %patch(E,F,G,[min(1,Ctot(i,1)) min(1,Ctot(i,2)) min(1,Ctot(i,3))]);
        %end
        end
end     
        
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%       View End       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%% %%%%%%%%   Perspective Projection   %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if(proj == 1)
          %figure
          %title('prospective projection')
          %set(0,'DefaultPatchEdgeColor','none');
          for i = 1 : 3*row
          C(i,:)  =  (C (i,:)* Tproj);
          C(i,:)  =  (C (i,:))/C(i,4);
          end
          for i = 1:3 : 3*row
              E =  [  C(i,1)  ;   C(i+1,1)   ;     C(i+2,1)];
              F = [  C(i,2)  ;   C(i+1,2)  ;     C(i+2,2)];
              G = [  C(i,3)  ;   C(i+1,3)  ;    C(i+2,3)];  
             %patch(E,F,G,[min(1,Ctot(i,1)) min(1,Ctot(i,2)) min(1,Ctot(i,3))]); 
           end 
      end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%% %%%%%%%%   Perspective Projection  End %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Z-Sorting %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (zsort==1)
z_values=[];
figure
title('After Z sorting')
set(0,'DefaultPatchEdgeColor','none');
xlim([-1,1]);  %%%%%%Limiting x and y axis %%%%%%%%%%%%%
ylim([-1,1]);
for i = 1:3:3*row
    calc=(C(i,3)+C(i+1,3)+C(i+2,3))/3
    for j=1:3
     z_values = [ z_values; calc];
    end
end
end

C=[C Ctot z_values];
C = sortrows(C, 8);
for i = 1:3 : 3*row
              E =  [  C(i,1)  ;   C(i+1,1)   ;     C(i+2,1)];
              F = [  C(i,2)  ;   C(i+1,2)  ;     C(i+2,2)];
              G = [  C(i,3)  ;   C(i+1,3)  ;    C(i+2,3)];  
             patch(E,F,[min(1,C(i,5)) min(1,C(i,6)) min(1,C(i,7))]); 
           end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Z-Sorting END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Clipping       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (clipping ==1)
figure
title('Final figure clipping ')
set(0,'DefaultPatchEdgeColor','none');
xlim([-1 1]);               %%%%%%Limiting x and y axis %%%%%%%%%%%%%
ylim([-1 1]);
for i = 1 : 3 : 3*row
     
            
         E = [  C(i,1)  ;   C(i+1,1)   ;     C(i+2,1)];
         F = [  C(i,2)  ;   C(i+1,2)  ;     C(i+2,2)];
         G = [  C(i,3)  ;   C(i+1,3)  ;    C(i+2,3)];  
             
          if( (0<G(1,1) && G(1,1)< 1 )||(0<G(2,1)  && G(2,1) < 1 )||(0<G(3,1)  && G(3,1) < 1 ))
             patch(E,F,[min(1,C(i,5)) min(1,C(i,6)) min(1,C(i,7))]); 
          end        
     end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Clipping Ends      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
