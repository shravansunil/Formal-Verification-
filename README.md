# Formal-Verification
Formal Verification flow using Yosys

  ## Equivalence Checking 

  ### The bash script 
  This script treats the circuit as a transition model and does equivalence checking using the Yosys Sat Solver. 

    ```tcl
    # 1. Load Circuit A and rename the module 'ref' to 'gold' since the design file had it named the same. 
    read_verilog circuit_A.v
    rename ref gold
    design -stash A
     
    # 2. Load Circuit B and rename the module 'ref' to 'gate'
    read_verilog circuit_B.v
    rename ref gate
    design -stash B
    
    # 3. Bring them into the current design
    design -copy-from A gold
    design -copy-from B gate
    
    # 4. Create the Miter
    # This gives inputs to both modules, XORs their outputs and ORs the result to a trigger port.
    miter -equiv -flatten -make_outputs gold gate miter_top
    
    # 5. Set the top and prepare
    hierarchy -top miter_top
    # Added '-top miter_top' to prep to ensure it focuses correctly
    prep -top miter_top
    
    # 6. Run Formal Verification
    # Check that the 'trigger' output is always 0 using k-induction.
    # Appended 'miter_top' at the end to explicitly target the miter module.
    sat -verify -seq 20 -tempinduct -prove trigger 0 miter_top
    
    # The seq 20 check ensures that the design is checked for an extended period of time so that it can be verified taking into consideration it's sequential   properties too.
    # The -tempinduct flag uses mathematical induction to prove that the sequential circuit remains function for much more than the 20 cycles that it has been time unrolled for

    ```
 
