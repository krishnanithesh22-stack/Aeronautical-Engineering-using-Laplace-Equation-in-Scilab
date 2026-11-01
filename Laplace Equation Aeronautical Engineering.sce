// --- 1. BOEING 737-800 PARAMETERS ---

m = 70000; // Boeing 737 max mass (kg)
g = 9.81; // Acceleration due gravity (ms^-2)
W = m * g; // Total Weight (N)

S = 124.6; // Wing Reference Area (m^2)
AR = 9.45; // Wing Aspect Ratio
e = 0.85; // Oswald efficiency factor

CD0 = 0.020; // Zero-lift drag coefficient (parasite drag)
K = 1 / (%pi * AR * e); // Induced drag factor

// --- 2. ATMOSPHERIC MODEL AT FL350 (35,000 ft / 10,668 m) ---

h = 10688; // Altitude (meters)
rho0 = 1.225; // Sea level air density (kgm^-3)
T0 = 288.15; // Sea level temperature (K)
L_rate = 0.0065; // Temperature laplace rate (Km^-1)
R_gas = 287.05; // Gas constant (J/kg.k)
gamma_air = 1.4; // Specific heat ratio

T_alt = T0 - (L_rate * h); // Ambient Temp (K)
rho = rho0 * ((T_alt / T0) ^ ((g / (L_rate * R_gas)) - 1 )); // Air Density
a = sqrt(gamma_air * R_gas * T_alt); // Speed of sound (ms^-1)

// --- 3. VELOCITY SWEEP & CALCULATIONS ---

V_kts = 150:2:500; // Velocity range in knots
V = V_kts * 0.514444; // Convert Velocity to ms^-1
q = 0.5 * rho * (V.^2); // Dynamic Pressure

// Aerodynamic Coefficients

CL = W ./ (q * S); 
CD = CD0 + K * (CL.^2);

// Forces & Power

Thrust_Req = q * S .* CD; // Total Thrust Required
Thrust_Parasite = q * S * CD0; // Parasite Drag
Thrust_Induced = q * S .* (K * (CL.^2)); // Induced Drag
Power_Req = (Thrust_Req .* V) / 1e6; // Power Required

L_over_D = CL ./ CD; // Lift-to-Drag Ratio

// --- 4. KEY OPTIMAL PERFORMANCE POINTS ---

CL_opt = sqrt(CD0 / K);
CD_opt = 2 * CD0;
LD_max = CL_opt / CD_opt;
V_LDmax = sqrt((2 * W) / (rho * S * CL_opt));
V_LDmax_kts = V_LDmax / 0.514444;
Mach_LDmax = V_LDmax / a;

// Print Summary to Console

mprintf("=====================================================\n");
mprintf("   BOEING 737-800 PERFORMANCE SUMMARY (FL350)\n");
mprintf("=====================================================\n");
mprintf("Air Density at Altitude : %.4f kg/m^3\n", rho);
mprintf("Speed of Sound          : %.2f m/s\n", a);
mprintf("-----------------------------------------------------\n");
mprintf("Maximum L/D Ratio (L/D)_max : %.2f\n", LD_max);
mprintf("Optimal Speed for Max L/D  : %.2f knots (Mach %.2f)\n", V_LDmax_kts, Mach_LDmax);
mprintf("Thrust Required at (L/D)max : %.2f kN\n", (W / LD_max)/1000);
mprintf("=====================================================\n");

// --- 5. GRAPHICAL PLOTS ---
scf(0);

// Subplot 1: Thrust Required vs Velocity
subplot(2, 1, 1);
plot(V_kts, Thrust_Req/1000, "b-", "LineWidth", 2);
plot(V_kts, Thrust_Parasite/1000, "r--", "LineWidth", 1.5);
plot(V_kts, Thrust_Induced/1000, "g--", "LineWidth", 1.5);

// Plot marker for minimum thrust point
plot(V_LDmax_kts, (W/LD_max)/1000, "ro", "MarkerSize", 8, "MarkerFaceColor", "red");

xtitle("Boeing 737-800 Thrust Required at FL350", "True Airspeed (Knots)", "Thrust / Drag (kN)");
legend(["Total Thrust Required"; "Parasite Drag"; "Induced Drag"; "Minimum Thrust Point (Max L/D)"]);
xgrid(1);

// Subplot 2: L/D Ratio vs Mach
subplot(2, 1, 2);
plot(V / a, L_over_D, "m-", "LineWidth", 2);

// Plot marker for max L/D point
plot(Mach_LDmax, LD_max, "ro", "MarkerSize", 8, "MarkerFaceColor", "red");

xtitle("Lift-to-Drag Ratio (L/D) vs Mach Number", "Mach Number", "L/D Ratio");
legend(["L/D Curve"; msprintf("Max L/D = %.2f at Mach %.2f", LD_max, Mach_LDmax)]);
xgrid(1);
