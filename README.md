
![Uploading 1.png…]()

# Optimization of Microgrids with Renewable Energy, Electric Vehicles, and Adaptive Demand Response

MATLAB research code for daily energy scheduling in a residential microgrid with solar and wind profiles, stationary batteries, home EV batteries, conventional generation, and utility supply.

**Release status: original research snapshot, reviewed statically and not executed in MATLAB.** The supplied files implement part of the framework. The full part exist under request

## Scope of the supplied implementation

The script reads 24 hourly rows for 40 participants, prepares renewable and demand profiles, and constructs an optimization problem through MATLAB's problem-based Optimization Toolbox interface. It allocates stationary batteries to participants 11–30 and home EV batteries to participants 21–30. The objective combines utility purchases, conventional generation, and storage charging/discharging terms.

| Feature | Status in the uploaded code |
| --- | --- |
| Solar and wind profiles | Data from excel files |
| Stationary battery scheduling | state variables and charge/discharge bounds |
| Home EV scheduling | time-dependent |
| Conventional generation | minimized |
| Utility supply |minimized |
| Forecast training and evaluation | data and algorithm exist under request |
| Optimized demand response | optimzed version available under request |
| Integer or binary decisions |linearized the Non-Convex situation|

 46 participants and a broader forecasting, trading, and demand response framework.

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

Keep the two MATLAB files and all three workbooks in the same folder, and make that folder MATLAB's current folder.

Run `Main` from the MATLAB Editor or Command Window.



## Contributions

saeid sheikhmemari


