/*
 * sg_udp_probe.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "sg_udp_probe".
 *
 * Model version              : 1.1
 * Simulink Coder version : 25.1 (R2025a) 21-Nov-2024
 * C++ source code generated on : Tue Feb 24 15:26:22 2026
 *
 * Target selection: speedgoat.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef sg_udp_probe_h_
#define sg_udp_probe_h_
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "slrealtime/libsrc/IP/udp.hpp"
#include "slrealtime/libsrc/IP/ip.hpp"
#include "slrealtime/libsrc/IP/socketFactory.hpp"
#include "sg_udp_probe_types.h"
#include "sg_udp_probe_cal.h"
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
struct B_sg_udp_probe_T {
  real_T UDP_1024_o2;                  /* '<Root>/UDP_1024' */
  real_T UDP_5000_o2;                  /* '<Root>/UDP_5000' */
  real_T UDP_50000_o2;                 /* '<Root>/UDP_50000' */
  real_T UDP_50001_o2;                 /* '<Root>/UDP_50001' */
  real_T UDP_8080_o2;                  /* '<Root>/UDP_8080' */
  uint8_T UDP_1024_o1[2048];           /* '<Root>/UDP_1024' */
  uint8_T UDP_5000_o1[2048];           /* '<Root>/UDP_5000' */
  uint8_T UDP_50000_o1[2048];          /* '<Root>/UDP_50000' */
  uint8_T UDP_50001_o1[2048];          /* '<Root>/UDP_50001' */
  uint8_T UDP_8080_o1[2048];           /* '<Root>/UDP_8080' */
};

/* Block states (default storage) for system '<Root>' */
struct DW_sg_udp_probe_T {
  void* UDP_1024_DWORK1;               /* '<Root>/UDP_1024' */
  void *UDP_1024_PWORK[2];             /* '<Root>/UDP_1024' */
  void* UDP_5000_DWORK1;               /* '<Root>/UDP_5000' */
  void *UDP_5000_PWORK[2];             /* '<Root>/UDP_5000' */
  void* UDP_50000_DWORK1;              /* '<Root>/UDP_50000' */
  void *UDP_50000_PWORK[2];            /* '<Root>/UDP_50000' */
  void* UDP_50001_DWORK1;              /* '<Root>/UDP_50001' */
  void *UDP_50001_PWORK[2];            /* '<Root>/UDP_50001' */
  void* UDP_8080_DWORK1;               /* '<Root>/UDP_8080' */
  void *UDP_8080_PWORK[2];             /* '<Root>/UDP_8080' */
  int_T UDP_1024_IWORK[3];             /* '<Root>/UDP_1024' */
  int_T UDP_5000_IWORK[3];             /* '<Root>/UDP_5000' */
  int_T UDP_50000_IWORK[3];            /* '<Root>/UDP_50000' */
  int_T UDP_50001_IWORK[3];            /* '<Root>/UDP_50001' */
  int_T UDP_8080_IWORK[3];             /* '<Root>/UDP_8080' */
};

/* Real-time Model Data Structure */
struct tag_RTM_sg_udp_probe_T {
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

  extern struct B_sg_udp_probe_T sg_udp_probe_B;

#ifdef __cplusplus

}

#endif

/* Block states (default storage) */
extern struct DW_sg_udp_probe_T sg_udp_probe_DW;

#ifdef __cplusplus

extern "C"
{

#endif

  /* Model entry point functions */
  extern void sg_udp_probe_initialize(void);
  extern void sg_udp_probe_step(void);
  extern void sg_udp_probe_terminate(void);

#ifdef __cplusplus

}

#endif

/* Real-time Model object */
#ifdef __cplusplus

extern "C"
{

#endif

  extern RT_MODEL_sg_udp_probe_T *const sg_udp_probe_M;

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
 * '<Root>' : 'sg_udp_probe'
 */
#endif                                 /* sg_udp_probe_h_ */
