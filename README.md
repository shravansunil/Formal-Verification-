# Formal-Verification
Formal Verification flow using Yosys

  ## Equivalence Checking 

  ### The bash script 
  This script treats the circuit as a transition model and does equivalence checking using the Yosys Sat Solver. This takes the design files which are given in the repo as circuit_A.v and circuit_B.v 

    verify.ys
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

  # BMC using SAT Solver 

  This script makes use of the counter.v file in the repo. 
  The test that is done here is whether the design goes into the state 11. Since it is technically impossible for the design to not go into 11 without the reset signal being held low, this test will definitely fail.
  The assertion is given as a part of the design itself within an IFDEF FORMAL block. 
  
  ## The bash script 

  bmc_script.ys
  ```tcl
  # 1. Read the Verilog file
  # The '-formal' flag is crucial here: it tells Yosys to define the 'FORMAL' macro and to translate the assert statements into mathematical rules.
  read_verilog -formal counter.v
  
  # 2. Prepare the design
  # This flattens the module and translates it into a state transition system.
  prep -top counter
  
  # 3. Run Bounded Model Checking using the internal SAT solver
  # -seq 5         : Observes for 5 clock cycles from present (our bound in BMC).
  # -prove-asserts : Tells the SAT solver to actively try to break our assert rule.
  # -show-ports    : If the solver breaks the rule, print out the input/output values.
  sat -seq 5 -prove-asserts -show-ports
  ```

<img width="1001" height="805" alt="image" src="https://github.com/user-attachments/assets/b0eff927-d602-4c54-b282-2ef5bf561b63" />

# BMC using SAT Solver - Liveliness Testing 
While the safety property checking tests for whether an undesirable event will ever happen, the liveness check will wait for a specified event to occur at some point. This is much more heavier on the SAT solver when modelling mathematically.
Thus this is often given as a Bounded Liveness property in the RTL design itself. 
The property being tested here is that the design 'will' go into state 00 eventually. 

counter_liveness.v is used as the design file here. 

    bmc_liveness.ys
    ```tcl
    # 1. Read the Verilog file
    read_verilog -formal counter_liveness.v
    
    # 2. Prepare the design
    prep -top counter
    
    # 3. Run Bounded Model Checking
    # -seq 10 : We check 10 clock cycles. This gives the counter plenty of time 
    #           to prove that our 4-cycle limit is never breached.
    sat -seq 10 -prove-asserts -show-ports
    ```

# Optimization and Equivalence Checking
The top module is a completely combinational circuit here and thus the SAT solver will not unroll the design in time. 
There will be two scripts that perform different functions at two stages. 
The first script will  
  1. A Ysosys script will read the design file
  2. Perform Logic Optimization for the design
  3. Generate the optimized RTL

The second script will 
  1. Load the original RTL
  2. Load the optimized Netlist
  3. Create a Miter circuit
  4. Perform Equivalence check

The top.v file is used as the design file here 

## OPTIMIZED NETLIST GENERATION bash script 


    ```tcl 
    # 1. Read the RTL file
    read_verilog top.v
    
    # 2. Prepare the design for processing
    prep -top top
    
    # 3. Perform logic optimization
    # The 'opt' command runs a series of optimization passes 
    opt
    
    # 4. Generate the optimized netlist and write it to a new file 
    write_verilog top_opt.v
    ```

## EQUIVALENCE CHECKING 

    ```tcl
    # This script is similar to the first one that we had in the first section 
    # 1. Load the original RTL 
    read_verilog top.v
    rename top gold
    design -stash gold_design
    
    # 2. Load the optimized netlist 
    read_verilog top_opt.v
    rename top gate
    design -stash gate_design
    
    # Bring both into our active workspace
    design -copy-from gold_design gold
    design -copy-from gate_design gate
    
    # 3. Create the miter circuit
    miter -equiv -flatten -make_outputs gold gate miter_top
    
    # Prepare the miter circuit for the solver
    prep -top miter_top
    
    # 4. Perform equivalence checking
    # Notice we DO NOT need -seq or -tempinduct here because there is no clock!
    sat -verify -prove trigger 0 miter_top
    ```







