/* Main generated for Simulink Real-Time model sg_eeg_20ch_rt */
#include <ModelInfo.hpp>
#include <utilities.hpp>
#include "rte_sg_eeg_20ch_rt_parameters.h"
#include "sg_eeg_20ch_rt.h"

/* Task wrapper function definitions */
void sg_eeg_20ch_rt_Task1(void)
{ 
    sg_eeg_20ch_rt_step();
} 
/* Task descriptors */
slrealtime::TaskInfo task_1( 0u, std::bind(sg_eeg_20ch_rt_Task1), slrealtime::TaskInfo::PERIODIC, 0.001, 0, 40);

/* Executable base address for XCP */
#ifdef __linux__
extern char __executable_start;
static uintptr_t const base_address = reinterpret_cast<uintptr_t>(&__executable_start);
#else
/* Set 0 as placeholder, to be parsed later from /proc filesystem */
static uintptr_t const base_address = 0;
#endif

/* Model descriptor */
slrealtime::ModelInfo sg_eeg_20ch_rt_Info =
{
    "sg_eeg_20ch_rt",
    sg_eeg_20ch_rt_initialize,
    sg_eeg_20ch_rt_terminate,
    []()->char const*& { return sg_eeg_20ch_rt_M->errorStatus; },
    []()->unsigned char& { return sg_eeg_20ch_rt_M->Timing.stopRequestedFlag; },
    { task_1 },
    slrealtime::getSegmentVector()
};

int main(int argc, char *argv[]) {
    slrealtime::BaseAddress::set(base_address);
    return slrealtime::runModel(argc, argv, sg_eeg_20ch_rt_Info);
}
