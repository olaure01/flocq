Require Import Fcore_Raux.
Require Import Fcore_defs.
Require Import Fcore_rnd.
Require Import Fcore_generic_fmt.
Require Import Fcore_float_prop.
Require Import Fcore_FLX.

Section RND_FTZ.

Variable beta : radix.

Notation bpow e := (bpow beta e).

Variable emin prec : Z.
Variable Hp : Zlt 0 prec.

(* floating-point format with abrupt underflow *)
Definition FTZ_format (x : R) :=
  exists f : float beta,
  x = F2R f /\ (x <> R0 -> Zpower (radix_val beta) (prec - 1) <= Zabs (Fnum f) < Zpower (radix_val beta) prec)%Z /\
  (emin <= Fexp f)%Z.

Definition FTZ_RoundingModeP (rnd : R -> R):=
  Rounding_for_Format FTZ_format rnd.

Definition FTZ_exp e := if Zlt_bool (e - prec) emin then (emin + prec - 1)%Z else (e - prec)%Z.

Theorem FTZ_exp_correct : valid_exp FTZ_exp.
Proof.
intros k.
unfold FTZ_exp.
generalize (Zlt_cases (k - prec) emin).
case (Zlt_bool (k - prec) emin) ; intros H1.
split ; intros H2.
omega.
split.
generalize (Zlt_cases (emin + prec + 1 - prec) emin).
case (Zlt_bool (emin + prec + 1 - prec) emin) ; intros H3.
omega.
generalize (Zlt_cases (emin + prec - 1 + 1 - prec) emin).
case (Zlt_bool (emin + prec - 1 + 1 - prec) emin) ; omega.
intros l H3.
generalize (Zlt_cases (l - prec) emin).
case (Zlt_bool (l - prec) emin) ; omega.
split ; intros H2.
generalize (Zlt_cases (k + 1 - prec) emin).
case (Zlt_bool (k + 1 - prec) emin) ; omega.
split ; intros ; omega.
Qed.

Theorem FTZ_format_generic :
  forall x : R, FTZ_format x <-> generic_format beta FTZ_exp x.
Proof.
split.
(* . *)
intros ((xm, xe), (Hx1, (Hx2, Hx3))).
destruct (Req_dec x 0) as [Hx4|Hx4].
rewrite Hx4.
apply generic_format_0.
specialize (Hx2 Hx4).
rewrite Hx1.
apply generic_format_canonic_exponent.
unfold canonic_exponent, FTZ_exp.
rewrite <- Hx1.
destruct (ln_beta beta x) as (ex, Hx6).
simpl.
specialize (Hx6 Hx4).
generalize (Zlt_cases (ex - prec) emin).
case (Zlt_bool (ex - prec) emin) ; intros H1.
elim (Rlt_not_le _ _ (proj2 Hx6)).
apply Rle_trans with (bpow (prec - 1) * bpow emin)%R.
rewrite <- bpow_add.
apply -> bpow_le.
omega.
rewrite Hx1, abs_F2R.
unfold F2R. simpl.
apply Rmult_le_compat.
apply bpow_ge_0.
apply bpow_ge_0.
rewrite <- Z2R_Zpower.
now apply Z2R_le.
apply Zle_minus_le_0.
now apply (Zlt_le_succ 0).
now apply -> bpow_le.
cut (ex - 1 < prec + xe)%Z. omega.
apply <- (bpow_lt beta).
apply Rle_lt_trans with (1 := proj1 Hx6).
rewrite Hx1.
apply F2R_lt_bpow.
simpl.
ring_simplify (prec + xe - xe)%Z.
apply Hx2.
(* . *)
intros Hx.
destruct (Req_dec x 0) as [Hx3|Hx3].
exists (Float beta 0 emin).
split.
unfold F2R. simpl.
now rewrite Rmult_0_l.
split.
intros H.
now elim H.
apply Zle_refl.
unfold generic_format, canonic_exponent, FTZ_exp in Hx.
destruct (ln_beta beta x) as (ex, Hx4).
simpl in Hx.
specialize (Hx4 Hx3).
generalize (Zlt_cases (ex - prec) emin) Hx. clear Hx.
case (Zlt_bool (ex - prec) emin) ; intros Hx5 Hx2.
elim Rlt_not_ge with (1 := proj2 Hx4).
apply Rle_ge.
rewrite Hx2, abs_F2R.
rewrite <- (Rmult_1_l (bpow ex)).
unfold F2R. simpl.
apply Rmult_le_compat.
now apply (Z2R_le 0 1).
apply bpow_ge_0.
apply (Z2R_le 1).
apply (Zlt_le_succ 0).
apply lt_Z2R.
apply Rmult_lt_reg_r with (bpow (emin + prec - 1)).
apply bpow_gt_0.
rewrite Rmult_0_l.
change (0 < F2R (Float beta (Zabs (Ztrunc (x * bpow (- (emin + prec - 1))))) (emin + prec - 1)))%R.
rewrite <- abs_F2R, <- Hx2.
now apply Rabs_pos_lt.
apply -> bpow_le.
omega.
rewrite Hx2.
eexists ; repeat split ; simpl.
apply le_Z2R.
rewrite Z2R_Zpower.
apply Rmult_le_reg_r with (bpow (ex - prec)).
apply bpow_gt_0.
rewrite <- bpow_add.
replace (prec - 1 + (ex - prec))%Z with (ex - 1)%Z by ring.
change (bpow (ex - 1) <= F2R (Float beta (Zabs (Ztrunc (x * bpow (- (ex - prec))))) (ex - prec)))%R.
rewrite <- abs_F2R, <- Hx2.
apply Hx4.
apply Zle_minus_le_0.
now apply (Zlt_le_succ 0).
apply lt_Z2R.
rewrite Z2R_Zpower.
apply Rmult_lt_reg_r with (bpow (ex - prec)).
apply bpow_gt_0.
rewrite <- bpow_add.
replace (prec + (ex - prec))%Z with ex by ring.
change (F2R (Float beta (Zabs (Ztrunc (x * bpow (- (ex - prec))))) (ex - prec)) < bpow ex)%R.
rewrite <- abs_F2R, <- Hx2.
apply Hx4.
now apply Zlt_le_weak.
now apply Zge_le.
Qed.

Theorem FTZ_format_satisfies_any :
  satisfies_any FTZ_format.
Proof.
refine (satisfies_any_eq _ _ _ (generic_format_satisfies_any beta FTZ_exp _)).
intros x.
apply iff_sym.
apply FTZ_format_generic.
exact FTZ_exp_correct.
Qed.

Theorem FTZ_format_FLXN :
  forall x : R,
  (bpow (emin + prec - 1) <= Rabs x)%R ->
  ( FTZ_format x <-> FLXN_format beta prec x ).
Proof.
intros x Hx.
split.
(* . *)
destruct (Req_dec x 0) as [H4|H4].
intros _.
rewrite H4.
apply -> FLX_format_FLXN.
apply <- FLX_format_generic.
apply generic_format_0.
exact Hp.
exact Hp.
intros ((xm,xe),(H1,(H2,H3))).
specialize (H2 H4).
rewrite H1.
eexists. split. split.
now intros _.
(* . *)
intros ((xm,xe),(H1,H2)).
rewrite H1.
eexists. split. split. split.
now rewrite <- H1 at 1.
rewrite (Zsucc_pred emin).
apply Zlt_le_succ.
apply <- (bpow_lt beta).
apply Rmult_lt_reg_l with (Z2R (Zabs xm)).
apply Rmult_lt_reg_r with (bpow xe).
apply bpow_gt_0.
rewrite Rmult_0_l.
rewrite H1, abs_F2R in Hx.
apply Rlt_le_trans with (2 := Hx).
apply bpow_gt_0.
rewrite H1, abs_F2R in Hx.
apply Rlt_le_trans with (2 := Hx).
replace (emin + prec - 1)%Z with (prec + (emin - 1))%Z by ring.
rewrite bpow_add.
apply Rmult_lt_compat_r.
apply bpow_gt_0.
rewrite <- Z2R_Zpower.
apply Z2R_lt.
apply H2.
intros H.
rewrite <- abs_F2R, <- H1, H, Rabs_right in Hx.
apply Rle_not_lt with (1 := Hx).
apply bpow_gt_0.
apply Rle_refl.
now apply Zlt_le_weak.
Qed.

End RND_FTZ.
