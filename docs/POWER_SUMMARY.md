# Power Analysis Summary

Power analysis is performed by the OpenROAD flow when enabled in OpenLane.

## Enabling Power Analysis

In OpenLane `config.tcl` or `config.json`:

```
set ::env(RUN_CVC) 1
set ::env(POWER_REPORT) 1
```

Post-route power reports are written to the OpenLane `runs` directory.

## Expected Order of Magnitude

For a 5-stage RV32IM core in Sky130 at 100 MHz:

- **Dynamic power:** ~1–10 mW (depends on activity)
- **Leakage:** ~0.1–1 mW

## Power Optimization

- Clock gating: Not implemented in current RTL
- Supply voltage: Defined by Sky130 PDK
- Activity factor: Depends on workload; use typical benchmarks for realistic estimates
