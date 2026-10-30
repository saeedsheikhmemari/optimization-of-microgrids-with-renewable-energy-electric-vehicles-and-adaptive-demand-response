# Optimization of Microgrids with Renewable Energy, Electric Vehicles, and Adaptive Demand Response

MATLAB research code for daily energy scheduling in a residential microgrid with solar and wind profiles, stationary batteries, home EV batteries, conventional generation, and utility supply.

**Release status: original research snapshot, reviewed statically and not executed in MATLAB.** The supplied files implement part of the manuscript framework. Read the [implementation review](docs/IMPLEMENTATION_REVIEW.md) before interpreting numerical outputs as physical schedules or manuscript reproduction.

## Scope of the supplied implementation

The script reads 24 hourly rows for 40 participants, prepares renewable and demand profiles, and constructs an optimization problem through MATLAB's problem-based Optimization Toolbox interface. It allocates stationary batteries to participants 11–30 and home EV batteries to participants 21–30. The objective combines utility purchases, conventional generation, and storage charging/discharging terms.

| Feature | Status in the uploaded code |
| --- | --- |
| Solar and wind profiles | Read from the supplied spreadsheets |
| Stationary battery scheduling | Active, with state variables and charge/discharge bounds |
| Home EV scheduling | Active, with time-dependent restrictions and randomized early charging |
| Conventional generation | Three nonnegative output arrays, each bounded by 2 per participant and time slot |
| Utility supply | Nonnegative import variable `G` |
| Forecast training and evaluation | Not included |
| Optimized demand response | Not included; demand remains an input |
| Grid exports | Not included as an active decision variable |
| Peer-to-peer trading | Related variables and constraints are commented out |
| Charging-station EVs | Related variables and constraints are commented out |
| Integer or binary decisions | None declared in the active code; the active expressions are linear |
| Automated comparison with EV participation disabled | Not included |

The manuscript discusses 46 participants and a broader forecasting, trading, and demand response framework. This snapshot should not be represented as a complete implementation of those features.

## Files

| File | Purpose |
| --- | --- |
| `Main.m` | Imports data, prepares profiles and prices, calls the optimization function, and creates plots and summaries |
| `func.m` | Defines optimization variables, objective terms, storage dynamics, and participant supply constraints |
| `Saeid_Work1_Data.xlsx` | Demand, PV, and wind profiles, each with 24 rows and 40 columns |
| `9.xlsx` | Electricity prices and battery parameters, alongside additional source sheets |
| `Sobhani_Data.xlsx` | Initial PV input, subsequently overwritten in `Main.m` |
| `docs/DATA.md` | Exact sheet ranges and transformations |
| `docs/IMPLEMENTATION_REVIEW.md` | Known modeling and reproducibility issues |
| `docs/VALIDATION.md` | Checks performed and checks still required |

## Requirements

- MATLAB with Optimization Toolbox for `optimvar`, `optimproblem`, and `solve`.
- Statistics and Machine Learning Toolbox for `unifrnd` as currently called.
- Spreadsheet import support for the legacy `xlsread` calls.
- An interactive MATLAB desktop for the existing plotting and `propedit` calls.

The source MATLAB release was not specified in the uploaded files. No release compatibility or solver execution has been verified. GNU Octave compatibility is not claimed.

## Running the supplied snapshot

Keep the two MATLAB files and all three workbooks in the same folder, and make that folder MATLAB's current folder. The workbook filenames are referenced without their `.xlsx` suffixes in the supplied script.

Run `Main` from the MATLAB Editor or Command Window. The script clears the workspace and closes existing figures before importing data. Outputs include the `linsol` solution structure, `fval`, participant-level arrays, printed totals, and figures. The script does not automatically export results to files.

For an attempted repeatable run, set an RNG seed immediately before running `Main`. The script uses `unifrnd` to fix early-hour EV charging values and contains no seed of its own. Record the seed, MATLAB release, toolbox versions, solver diagnostics, and any source changes with each experiment.

Model construction may require correction before a successful solve: the function repeatedly assigns vector-valued expressions to an optimization problem's objective before summing them. See the implementation review. No successful run is bundled or implied.

## Interpreting outputs

The active model has known issues affecting energy accounting and storage feasibility. In particular, EV discharge is counted twice in EV-equipped participants' supply constraints, and an EV state transition is missing. The supply constraints use inequalities and there is no explicit export or curtailment variable to explain surplus energy.

The release therefore does not assert forecasting accuracy, percentage savings, emissions reductions, resilience performance, or reproduction of manuscript tables. These require a corrected, versioned model and verified experiments.

## Contributions

Please describe the exact input, MATLAB version, error message, and expected behavior when reporting an issue. Changes to equations, units, objective terms, or physical constraints should be documented together with their effects on results. Preserve the original snapshot when developing a corrected version.

## Attribution and licensing

This repository accompanies the author's microgrid research. A DOI, final publication record, and complete citation metadata were not supplied with the code and are not invented here. No software or dataset license has yet been selected for this snapshot. Public availability does not itself establish reuse permissions; licensing and original dataset provenance should be completed by the owner.
