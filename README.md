# Formal-Verification
Formal Verification flow using Yosys

## Equivalence Checking 

### The bash script 
This script treats the circuit as a transition model and does equivalence checking using the Yosys Sat Solver. 

'''tcl
# 1. Load Circuit A
read_verilog circuit_A.v
# Rename the module 'ref' to 'gold' so we can identify it
rename ref gold
design -stash A
'''

# 2. Load Circuit B
read_verilog circuit_B.v
# Rename the module 'ref' to 'gate'
rename ref gate
design -stash B

# 3. Bring them into the current design
design -copy-from A gold
design -copy-from B gate

# 4. Create the Miter
# This forwards inputs to both modules, XORs their outputs, 
# and ORs the result to a 'trigger' port.
miter -equiv -flatten -make_outputs gold gate miter_top

# 5. Set the top and prepare
hierarchy -top miter_top
# Added '-top miter_top' to prep to ensure it focuses correctly
prep -top miter_top

# 6. Run Formal Verification
# Check that the 'trigger' output is always 0 using k-induction.
# Appended 'miter_top' at the end to explicitly target the miter module.
sat -verify -seq 20 -tempinduct -prove trigger 0 miter_top
