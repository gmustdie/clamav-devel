; RUN: opt < %s -scalarrepl -instcombine | \
; RUN:   llc -march=x86 -mcpu=yonah | not grep sub.*esp
; XFAIL: *

; This checks that various insert/extract idiom work without going to the
; stack.

define void @test(<4 x float>* %F, float %f) {
entry:
	%tmp = load <4 x float>* %F		; <<4 x float>> [#uses=2]
	%tmp3 = fadd <4 x float> %tmp, %tmp		; <<4 x float>> [#uses=1]
	%tmp10 = insertelement <4 x float> %tmp3, float %f, i32 0		; <<4 x float>> [#uses=2]
	%tmp6 = fadd <4 x float> %tmp10, %tmp10		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp6, <4 x float>* %F
	ret void
}

define void @test2(<4 x float>* %F, float %f) {
entry:
	%G = alloca <4 x float>, align 16		; <<4 x float>*> [#uses=3]
	%tmp = load <4 x float>* %F		; <<4 x float>> [#uses=2]
	%tmp3 = fadd <4 x float> %tmp, %tmp		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp3, <4 x float>* %G
	%tmp.upgrd.1 = getelementptr <4 x float>* %G, i32 0, i32 2		; <float*> [#uses=1]
	store float %f, float* %tmp.upgrd.1
	%tmp4 = load <4 x float>* %G		; <<4 x float>> [#uses=2]
	%tmp6 = fadd <4 x float> %tmp4, %tmp4		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp6, <4 x float>* %F
	ret void
}

define void @test3(<4 x float>* %F, float* %f) {
entry:
	%G = alloca <4 x float>, align 16		; <<4 x float>*> [#uses=2]
	%tmp = load <4 x float>* %F		; <<4 x float>> [#uses=2]
	%tmp3 = fadd <4 x float> %tmp, %tmp		; <<4 x float>> [#uses=1]
	store <4 x float> %tmp3, <4 x float>* %G
	%tmp.upgrd.2 = getelementptr <4 x float>* %G, i32 0, i32 2		; <float*> [#uses=1]
	%tmp.upgrd.3 = load float* %tmp.upgrd.2		; <float> [#uses=1]
	store float %tmp.upgrd.3, float* %f
	ret void
}

define void @test4(<4 x float>* %F, float* %f) {
entry:
	%tmp = load <4 x float>* %F		; <<4 x float>> [#uses=2]
	%tmp5.lhs = extractelement <4 x float> %tmp, i32 0		; <float> [#uses=1]
	%tmp5.rhs = extractelement <4 x float> %tmp, i32 0		; <float> [#uses=1]
	%tmp5 = fadd float %tmp5.lhs, %tmp5.rhs		; <float> [#uses=1]
	store float %tmp5, float* %f
	ret void
}
