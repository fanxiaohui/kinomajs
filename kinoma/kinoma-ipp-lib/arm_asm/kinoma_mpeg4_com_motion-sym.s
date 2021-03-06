;;
;;     Copyright (C) 2010-2015 Marvell International Ltd.
;;     Copyright (C) 2002-2010 Kinoma, Inc.
;;
;;     Licensed under the Apache License, Version 2.0 (the "License");
;;     you may not use this file except in compliance with the License.
;;     You may obtain a copy of the License at
;;
;;      http://www.apache.org/licenses/LICENSE-2.0
;;
;;     Unless required by applicable law or agreed to in writing, software
;;     distributed under the License is distributed on an "AS IS" BASIS,
;;     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;     See the License for the specific language governing permissions and
;;     limitations under the License.
;;
#ifdef __GCCE__

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@; Macro to start a function	
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro START_FUNC	name
	.text
	.align 2
	.global \name
	.type \name,%function

\name:
.endm

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@; Macro to end a function	
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro END_FUNC	name
	@nuttin''?
.endm

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;;							Directive Generation						;;;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@;	AREA |.drectve|, ALIGN=0 ; FLAGS=0x100A00, INFO, REMOVE	
@;	DCB	"   "
@;	DCB	"/DEFAULTLIB:\"MSVCRTD\" "
@;	DCB	"/DEFAULTLIB:\"OLDNAMES\" "

@;	IMPORT  ippiCopy8x8HP_8u_C1R_arm

@	AREA |.text|, CODE, READONLY
@	CODE32

	START_FUNC	ippiAdd8x8HP_16s8u_C1RS_arm

	stmdb       sp!, {r4 - r11, lr}
	sub         sp, sp, #8
	mov         r5, r3
	mov         r6, r2
	mov         r7, r1
	mov         r9, r0
	ldr         r10, [sp, #0x30]
	ldr         r8, [sp, #0x2C]
	ldr         lr, [sp, #0x38]
	ldr         r4, [sp, #0x34]
	mov         r3, r10
	mov         r2, r8
	mov         r1, r5
	mov         r0, r6
	str         lr, [sp, #4]
	str         r4, [sp]
	bl          ippiCopy8x8HP_8u_C1R_arm
	mov         r0, r7, asr #1
	mov         r1, #8
	mov			r11, #255

loop:
	ldrsh       r2, [r9]
	ldr			r12, [r8]
	and			r3, r11, r12
	add         r5, r2, r3
	cmp         r5, r11
	bichi		r5, r11, r5, asr #31

	ldrsh       r2, [r9, #2]
	and			r3, r11, r12, lsr #8
	add         r3, r2, r3
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #8

	ldrsh       r2, [r9, #4]
	and			r3, r11, r12, lsr #16
	add         r3, r2, r3
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #16

	ldrsh       r2, [r9, #6]
	add         r3, r2, r12, lsr #24
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #24

	str         r5, [r8]

	ldrsh       r2, [r9, #8]
	ldr			r12, [r8, #4]
	and			r3, r11, r12
	add         r5, r2, r3
	cmp         r5, r11
	bichi		r5, r11, r5, asr #31

	ldrsh       r2, [r9, #0xA]
	and			r3, r11, r12, lsr #8
	add         r3, r2, r3
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #8

	ldrsh       r2, [r9, #0xC]
	and			r3, r11, r12, lsr #16
	add         r3, r2, r3
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #16

	ldrsh       r2, [r9, #0xE]
	add         r9, r9, r0, lsl #1
@	pld			[r9]
	add         r3, r2, r12, lsr #24
	cmp         r3, r11
	bichi		r3, r11, r3, asr #31
	orr			r5, r5, r3, lsl #24

	str         r5, [r8, #4]

	add         r8, r8, r10
	subs        r1, r1, #1
@	pld			[r8]
	bgt         loop

	mov         r0, #0
	add         sp, sp, #8
	ldmia       sp!, {r4 - r11, pc}

	END_FUNC	ippiAdd8x8HP_16s8u_C1RS_arm

    .balign 16

src			.req r0
srcStep		.req r1
dst			.req r2
dstStep		.req r3
acc			.req r4
rounding	.req r5
rows		.req r12

	START_FUNC	ippiCopy8x8HP_8u_C1R_arm
	
	stmfd    sp!,{r4-r11, lr}		@ ; 9 registers, 36 bytes

	mov      rows, #8
	b        ippiCopy8xnHP_8u_C1R_arm_after_rows

	END_FUNC

	START_FUNC	ippiCopy8xnHP_8u_C1R_arm

	stmfd    sp!,{r4-r11, lr}		@ ; 9 registers, 36 bytes

	ldr      rows, [sp, #44]
ippiCopy8xnHP_8u_C1R_arm_after_rows:
	ldr      rounding, [sp, #40]
	ldr      acc, [sp, #36]

	orr      r6, rounding, acc, lsl #1
	and      r7, src, #3
	orr      r6, r7, r6, lsl #2		@ ; r6 = (acc << 3) | (rounding << 2) | (src & 3) -> 32 choices
	adr      r7, procs
	ldr      pc, [r7, +r6, lsl #2]

procs:
	.long      acc0_align_0
	.long      acc0_align_1
	.long      acc0_align_2
	.long      acc0_align_3

	.long      acc0_align_0
	.long      acc0_align_1
	.long      acc0_align_2
	.long      acc0_align_3

	.long      acc1_round_align_0
	.long      acc1_round_align_1
	.long      acc1_round_align_2
	.long      acc1_round_align_3

	.long      acc1_no_round_align_0
	.long      acc1_no_round_align_1
	.long      acc1_no_round_align_2
	.long      acc1_no_round_align_3

	.long      acc2_round_align_0
	.long      acc2_round_align_1
	.long      acc2_round_align_2
	.long      acc2_round_align_3

	.long      acc2_no_round_align_0
	.long      acc2_no_round_align_1
	.long      acc2_no_round_align_2
	.long      acc2_no_round_align_3

	.long      acc3_round_align_0
	.long      acc3_round_align_1
	.long      acc3_round_align_2
	.long      acc3_round_align_3

	.long      acc3_no_round_align_0
	.long      acc3_no_round_align_1
	.long      acc3_no_round_align_2
	.long      acc3_no_round_align_3

data_fe:
	.long      0xfefefefe

@----------------------------
.macro	RETURN
		ldmfd    sp!,{r4-r11, pc}		@ ; return
.endm

@----------------------------
.macro	UNIMPLEMENTED
		mov      r0, #1
		RETURN
.endm

@----------------------------
.macro	DO_ALIGN	s0, s1, s2, align
		mov		\s0, \s0, lsr #(\align * 8)
		orr		\s0, \s0, \s1, lsl #(32 - \align * 8)
		mov		\s1, \s1, lsr #(\align * 8)
		orr		\s1, \s1, \s2, lsl #(32 - \align * 8)		
.endm

@----------------------------
.macro COPY_ALIGN d0, d1, s0, s1, s2, align
		mov		\d0, \s0, lsr #(\align * 8)
		mov		\d1, \s1, lsr #(\align * 8)
		orr		\d0, \d0, \s1, lsl #(32 - \align * 8)
		orr		\d1, \d1, \s2, lsl #(32 - \align * 8)		
.endm
	
@----------------------------

.macro AVERAGE_ROUND d0, d1, s0, s1, t0, t1, mask
        eor		\d0, \s0, \t0
        eor		\d1, \s1, \t1
        orr		\s0, \s0, \t0
        orr		\s1, \s1, \t1
        and		\d0, \d0, \mask
        and		\d1, \d1, \mask
        sub		\d0, \s0, \d0, lsr #1
        sub		\d1, \s1, \d1, lsr #1
.endm

@----------------------------
.macro AVERAGE_NO_ROUND d0, d1, s0, s1, t0, t1, mask
        eor		\d0, \s0, \t0
        eor		\d1, \s1, \t1
        and		\s0, \s0, \t0
        and		\s1, \s1, \t1
        and		\d0, \d0, \mask
        and		\d1, \d1, \mask
        add		\d0, \s0, \d0, lsr #1
        add		\d1, \s1, \d1, lsr #1
.endm

@----------------------------
.macro COPY align
	.if \align
		bic			src, src, #3					@ ; align source
loop\align:
		ldmia		src, {r6, r7, r8}
		add			src, src, srcStep
		DO_ALIGN	r6, r7, r8, \align
		stmia		dst, {r6, r7}
@		pld			[src]
		subs		rows, rows, #1
		add			dst, dst, dstStep
		bgt			loop\align
	.else
loop\align:
		ldmia		src, {r6, r7}
		add			src, src, srcStep
		stmia		dst,{ r6, r7}
@		pld			[src]
		subs		rows, rows, #1
		add			dst, dst, dstStep
		bgt			loop\align
	.endif

		RETURN
.endm

@----------------------------
.macro	ACC1 align, round

	ldr			r4, data_fe

	.if \align
		bic			src, src, #3					@ ; align source
	.endif
acc1\align\round:
		ldmia		src, {r6, r7, r8}
		add			src, src, srcStep
	.if (!\align)
		COPY_ALIGN	r9, r10, r6, r7, r8, 1
@		pld			[src]
		.if !\round
			AVERAGE_NO_ROUND r11, lr, r6, r7, r9, r10, r4
		.else
			AVERAGE_ROUND r11, lr, r6, r7, r9, r10, r4
		.endif		
		stmia		dst, {r11, lr}
	.endif
	.if !(\align - 1)
		COPY_ALIGN	r9, r10, r6, r7, r8, 1
		COPY_ALIGN	r11, lr, r6, r7, r8, 2
@		pld			[src]
		.if !(\round)
			AVERAGE_NO_ROUND r6, r7, r11, lr, r9, r10, r4
		.else
			AVERAGE_ROUND r6, r7, r11, lr, r9, r10, r4
		.endif		
		stmia		dst, {r6, r7}
	.endif
	.if !(\align - 2)
		COPY_ALIGN	r9, r10, r6, r7, r8, 2
		COPY_ALIGN	r11, lr, r6, r7, r8, 3
@		pld			[src]
		.if !(\round)
			AVERAGE_NO_ROUND r6, r7, r11, lr, r9, r10, r4
		.else
			AVERAGE_ROUND r6, r7, r11, lr, r9, r10, r4
		.endif		
		stmia		dst, {r6, r7}
	.endif
	.if !(\align - 3)
		COPY_ALIGN	r9, r10, r6, r7, r8, 3
@		pld			[src]
		.if !(\round)
			AVERAGE_NO_ROUND r11, lr, r7, r8, r9, r10, r4
		.else
			AVERAGE_ROUND r11, lr, r7, r8, r9, r10, r4
		.endif		
		stmia		dst, {r11, lr}
	.endif

		subs		rows, rows, #1
		add			dst, dst, dstStep
		bgt			acc1\align\round

		RETURN
.endm

@----------------------------
.macro	ACC2 align, round

	ldr			r4, data_fe

	.if !(\align)
		ldmia		src, {r6, r7}
		add			src, src, srcStep
	.else
		bic			src, src, #3					@ ; align source
		ldmia		src, {r6, r7, r8}
@		pld			[src]
		add			src, src, srcStep
		DO_ALIGN	r6, r7, r8, \align
	.endif

acc2\align\round:
	.if !(\align)
		ldmia		src, {r9, r10}
		add			src, src, srcStep
@		pld			[src]
	.else
		ldmia		src, {r9, r10, r11}
		add			src, src, srcStep
@		pld			[src]
		DO_ALIGN	r9, r10, r11, \align
	.endif

	.if !(\round)
		AVERAGE_NO_ROUND r11, lr, r6, r7, r9, r10, r4
	.else
		AVERAGE_ROUND r11, lr, r6, r7, r9, r10, r4
	.endif		
		stmia		dst, {r11, lr}
		add			dst, dst, dstStep

	.if !(\align)
		ldmia		src, {r6, r7}
		add			src, src, srcStep
@		pld			[src]
	.else
		ldmia		src, {r6, r7, r8}
		add			src, src, srcStep
@		pld			[src]
		DO_ALIGN	r6, r7, r8, \align
	.endif

	.if !(\round)
		AVERAGE_NO_ROUND r11, lr, r9, r10, r6, r7, r4
	.else
		AVERAGE_ROUND r11, lr, r9, r10, r6, r7, r4
	.endif		
		stmia		dst, {r11, lr}

		subs		rows, rows, #2
		add			dst, dst, dstStep
		bgt			acc2\align\round

		RETURN
.endm

@----------------------------
.macro	GET_AVERAGE_ROW	align, round	

	.if !(\align)
		ldmia		src, {r6-r8}
		add			src, src, srcStep
@        pld			[src]

        COPY_ALIGN	r4, r5, r6, r7, r8, 1
	.endif
	.if !(\align - 1)
		ldmia		src, {r8-r10}
		add			src, src, srcStep
@		pld			[src]

		COPY_ALIGN	r4, r5, r8, r9, r10, 1
		COPY_ALIGN	r6, r7, r8, r9, r10, 2
	.endif
	.if !(\align - 2)
		ldmia		src, {r8-r10}
		add			src, src, srcStep
@		pld			[src]

		COPY_ALIGN	r4, r5, r8, r9, r10, 2
		COPY_ALIGN	r6, r7, r8, r9, r10, 3
	.endif
	.if !(\align - 3)
		ldmia		src, {r5-r7}
		add			src, src, srcStep
@		pld			[src]

		COPY_ALIGN	r4, r5, r5, r6, r7, 3
	.endif

	.if (\round - 2)
		tst			rows, #1
	.endif
		and			r8, r4, lr
		and			r9, r5, lr
		and			r10, r6, lr
		and			r11, r7, lr

		add			r8, r8, r10
		add			r9, r9, r11

	.if (\round - 2)
	.if !(\round)
		andeq		r10, lr, lr, lsr #1			@ ; r10 = 0x01010101
	.else
		andeq		r10, lr, lr, lsl #1			@ ; r10 = 0x02020202
	.endif

		addeq		r8, r8, r10
		addeq		r9, r9, r10
	.endif

		mvn			r10, lr, lsl #6				@ ; r10 = 0x3f3f3f3f
		and			r4, r10, r4, lsr #2
		and			r5, r10, r5, lsr #2
		and			r6, r10, r6, lsr #2
		and			r7, r10, r7, lsr #2
		add			r10, r4, r6
		add			r11, r5, r7
.endm

@----------------------------
.macro	ACC3 align, round
	.if (\align)
		bic				src, src, #3					@ ; align source
	.endif
		ldr				lr, c_03030303					@ ; lr initialized to 03030303 required by GET_AVERAGE_ROW and ACC3

		GET_AVERAGE_ROW	\align, 2						@ ; force no rounding on first row
acc3\align\round:
		stmfd			sp!, {r8, r9, r10, r11}
		GET_AVERAGE_ROW	\align, \round
		ldmfd			sp!, {r4, r5, r6, r7}

		add				r4, r4, r8
		add				r5, r5, r9
		add				r6, r6, r10
		add				r7, r7, r11
		orr				lr, lr, lr, lsl #2				@ ; lr = 0x0f0f0f0f
		and				r4, lr, r4, lsr #2
		and				r5, lr, r5, lsr #2
		and				lr, lr, lr, lsr #2				@ ; lr = 0x03030303
		add				r4, r4, r6
		add				r5, r5, r7

		stmia			dst, {r4, r5}
		subs			rows, rows, #1
		add				dst, dst, dstStep
		bgt				acc3\align\round

		RETURN
.endm

acc0_align_0:
	COPY 0
acc0_align_1:
	COPY 1
acc0_align_2:
	COPY 2
acc0_align_3:
	COPY 3

acc1_no_round_align_0:
	ACC1 0, 0
acc1_no_round_align_1:
	ACC1 1, 0
acc1_no_round_align_2:
	ACC1 2, 0
acc1_no_round_align_3:
	ACC1 3, 0

acc1_round_align_0:
	ACC1 0, 1
acc1_round_align_1:
	ACC1 1, 1
acc1_round_align_2:
	ACC1 2, 1
acc1_round_align_3:
	ACC1 3, 1

acc2_no_round_align_0:
	ACC2 0, 0
acc2_no_round_align_1:
	ACC2 1, 0
acc2_no_round_align_2:
	ACC2 2, 0
acc2_no_round_align_3:
	ACC2 3, 0

acc2_round_align_0:
	ACC2 0, 1
acc2_round_align_1:
	ACC2 1, 1
acc2_round_align_2:
	ACC2 2, 1
acc2_round_align_3:
	ACC2 3, 1

acc3_no_round_align_0:
	ACC3 0, 0
acc3_no_round_align_1:
	ACC3 1, 0
acc3_no_round_align_2:
	ACC3 2, 0
acc3_no_round_align_3:
	ACC3 3, 0

acc3_round_align_0:
	ACC3 0, 1
acc3_round_align_1:
	ACC3 1, 1
acc3_round_align_2:
	ACC3 2, 1
acc3_round_align_3:
	ACC3 3, 1

c_03030303:
	.long      0x03030303

	END_FUNC	ippiCopy8x8HP_8u_C1R_arm

#endif /* __GCCE__ */
