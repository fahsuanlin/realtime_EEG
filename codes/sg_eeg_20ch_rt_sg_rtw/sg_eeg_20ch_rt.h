/*
 * sg_eeg_20ch_rt.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "sg_eeg_20ch_rt".
 *
 * Model version              : 1.5
 * Simulink Coder version : 25.1 (R2025a) 21-Nov-2024
 * C++ source code generated on : Tue Feb 24 16:36:39 2026
 *
 * Target selection: speedgoat.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef sg_eeg_20ch_rt_h_
#define sg_eeg_20ch_rt_h_
#include <logsrv.h>
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "verify/verifyIntrf.h"
#include "slrealtime/libsrc/IP/udp.hpp"
#include "slrealtime/libsrc/IP/ip.hpp"
#include "slrealtime/libsrc/IP/socketFactory.hpp"
#include "sg_eeg_20ch_rt_types.h"
#include "sg_eeg_20ch_rt_cal.h"
#include <cstring>

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   ((rtm)->Timing.taskTime0)
#endif

/* Block signals (default storage) */
struct B_sg_eeg_20ch_rt_T {
  real_T UDPReceive_o2;                /* '<Root>/UDP Receive' */
  real_T y[20];                        /* '<Root>/Decode20' */
  uint8_T UDPReceive_o1[1228];         /* '<Root>/UDP Receive' */
};

/* Block states (default storage) for system '<Root>' */
struct DW_sg_eeg_20ch_rt_T {
  void* UDPReceive_DWORK1;             /* '<Root>/UDP Receive' */
  void *UDPReceive_PWORK[2];           /* '<Root>/UDP Receive' */
  struct {
    void *LoggedData;
  } Scope20_PWORK;                     /* '<Root>/Scope20' */

  struct {
    void *AQHandles;
  } TAQOutportLogging_InsertedFor_D;   /* synthesized block */

  int32_T sfEvent;                     /* '<Root>/Decode20' */
  int_T UDPReceive_IWORK[3];           /* '<Root>/UDP Receive' */
  boolean_T doneDoubleBufferReInit;    /* '<Root>/Decode20' */
};

/* External outputs (root outports fed by signals with default storage) */
struct ExtY_sg_eeg_20ch_rt_T {
  real_T EEG20_Out[20];                /* '<Root>/EEG20_Out' */
};

/* Real-time Model Data Structure */
struct tag_RTM_sg_eeg_20ch_rt_T {
  const char_T *errorStatus;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    time_T taskTime0;
    uint32_T clockTick0;
    uint32_T clockTickH0;
    time_T stepSize0;
    boolean_T stopRequestedFlag;
  } Timing;
};

/* Block signals (default storage) */
#ifdef __cplusplus

extern "C"
{

#endif

  extern struct B_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_B;

#ifdef __cplusplus

}

#endif

/* Block states (default storage) */
extern struct DW_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_DW;

#ifdef __cplusplus

extern "C"
{

#endif

  /* External outputs (root outports fed by signals with default storage) */
  extern struct ExtY_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_Y;

#ifdef __cplusplus

}

#endif

#ifdef __cplusplus

extern "C"
{

#endif

  /* Model entry point functions */
  extern void sg_eeg_20ch_rt_initialize(void);
  extern void sg_eeg_20ch_rt_step(void);
  extern void sg_eeg_20ch_rt_terminate(void);

#ifdef __cplusplus

}

#endif

/* Real-time Model object */
#ifdef __cplusplus

extern "C"
{

#endif

  extern RT_MODEL_sg_eeg_20ch_rt_T *const sg_eeg_20ch_rt_M;

#ifdef __cplusplus

}

#endif

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'sg_eeg_20ch_rt'
 * '<S1>'   : 'sg_eeg_20ch_rt/Decode20'
 */
#endif                                 /* sg_eeg_20ch_rt_h_ */
