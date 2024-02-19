# misc-public
Place to store random files for public consumption

- pktd.ps1 : Powershell script to pin threads to cores using Windows affinity mask. This version is for pinning some workloads to P cores and some to E cores and specifically a Core i7-1270P (4P+8E). You need to work out which ones are which. Normaly Windows enumerates P-HT0 then P-HT1 then E. Realistically this is useful for delivering SLA’s for workloads. Doesn’t have to be P/E core, could easily be modified to pin specific workloads to specific cores which is useful for manual NUMA/cache locality and mapping processes to sockets where PCIe cards are directly attached to avoid UPI congestion and improve latencies. Us HPC people and network people do this all the time.
