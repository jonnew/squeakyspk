;;;--------------------------------------------------------------------

;;          AUTOCLASS C Test suite: 

;; when running with CodeCenter, ObjectCenter, or TestCenter replace "autoclass" with "run"

;;;------------------------------------------------------------------------
;;; input checking tests
            
;;;             S-PARAMS ERROR MSGS
% yes
% autoclass -search data/input-check/test.db2 data/input-check/test.hd2 \
                data/input-check/test.model data/input-check/first-test-0.s-params

;;;             HD2 & DB2 WARNING & ERROR MSGS 
% yes
% autoclass -search data/input-check/test.db2 data/input-check/test.hd2 \
                data/input-check/test.model data/input-check/first-test.s-params

% yes
% autoclass -search data/input-check/test.db2 data/input-check/test-0.hd2 \
                data/input-check/test.model data/input-check/first-test.s-params

% yes
% autoclass -search data/input-check/test-00.db2 data/input-check/test-0.hd2 \
                data/input-check/test.model data/input-check/first-test.s-params

% yes
% autoclass -search data/input-check/test-0.db2 data/input-check/test-0.hd2 \
                data/input-check/test.model data/input-check/first-test.s-params

;;; 		RESPOND TO ERROR MSGS IN .DB2 => TEST-1.DB2 
% yes
% autoclass -search data/input-check/test-1.db2 data/input-check/test-0.hd2 \
                data/input-check/test.model data/input-check/first-test.s-params


;;; 		RESPOND TO WARNING MSGS & ERROR MSGS IN .HD2 => TEST-1.HD2 TOO
;;;             check errors flagged in generate_attribute_info, extend_terms, &
;;;             extend_default_terms by looking at code and preturbing test-1.model
% yes
% autoclass -search data/input-check/test-1.db2 data/input-check/test-1.hd2 \
                data/input-check/test-1.model data/input-check/first-test.s-params


;;; 		WARNING MSGS ONLY IN .HD2 => TEST-2.HD2 TOO
% yes
% autoclass -search data/input-check/test-1.db2 data/input-check/test-2.hd2 \
                data/input-check/test-2.model data/input-check/first-test.s-params


;;;             WRONG MODEL TERM TYPE 
% yes
% autoclass -search data/input-check/test-1.db2 data/input-check/test-2.hd2 \
                data/input-check/test-3.model data/input-check/first-test.s-params


;;; MODEL TERM EXPANSION MSGS --  SINGLE-NORMAL-CM MODEL & TOO MAY CLASSES FOR DATA
% yes                  
% autoclass -search data/input-check/test-cm.db2 data/input-check/test-cm.hd2 \
                data/input-check/test-cm.model data/input-check/first-test.s-params

% yes                   reply no to proceed from warnings                    
% autoclass -search data/input-check/test-cm-1.db2 data/input-check/test-cm.hd2 \
                data/input-check/test-cm.model data/input-check/first-test-1.s-params


;;; MODEL TERM EXPANSION MSGS --  SINGLE-NORMAL-CN MODEL
% yes
% autoclass -search data/input-check/test-cn.db2 data/input-check/test-cn.hd2 \
                data/input-check/test-cn.model data/input-check/first-test.s-params

% yes
% autoclass -search data/input-check/test-cn-1.db2 data/input-check/test-cn.hd2 \
                data/input-check/test-cn.model data/input-check/first-test.s-params

% yes
% autoclass -search data/input-check/test-cn-2.db2 data/input-check/test-cn.hd2 \
                data/input-check/test-cn.model data/input-check/first-test.s-params


;;;---------------------------------------------------------------------------------------
;;; CHECK-POINTING
;;;---------------------------------------------------------------------------------------

% autoclass -search data/glass/glassc.db2 data/glass/glass-3c.hd2 data/glass/glass-mnc.model data/glass/glassc-chkpt.s-params

Run 1)
## glassc-chkpt.s-params
max_n_tries = 2
force_new_search_p = true
## --------------------
;; run to completion

Run 2)
## glassc-chkpt.s-params
force_new_search_p = false
max_n_tries = 10
checkpoint_p = true
min_checkpoint_period = 2
## --------------------
;; after first checkpoint, ctrl-C to abort

Run 3)
## glassc-chkpt.s-params
force_new_search_p = false
max_n_tries = 1
checkpoint_p = true
min_checkpoint_period = 1
reconverge_type = "chkpt"
## --------------------
;; checkpointed trial should finish 

Run 4)
## reconverge checkpointed clsf with another try function
## glassc-chkpt.s-params
force_new_search_p = false
try_fn_type = "converge_search_4"
max_n_tries = 1
reconverge_type = "results"
## --------------------
;; this trial should start and complete with a slightly better log marginal value
;; than the previous trial


;;;-------------------------------------------------------------
;;; BLOCK-SET-CLSF TESTS (.s-params files configured for **non**-random trials)
;;;-------------------------------------------------------------

;;; MODEL: SINGLE-NORMAL-CN START-FN: BLOCK-SET-CLSF MODEL: -- RNA
;;;             (att-type = real, att-subtype = scalar)
;;; yes
% autoclass -search data/rna/rnac.db2 data/rna/rnac.hd2 data/rna/rnac.model data/rna/rnac.s-params

% autoclass -reports data/rna/rnac.results-bin data/rna/rnac.search data/rna/rnac.r-params

% autoclass -predict data/rna/rnac-predict.db2 data/rna/rnac.results-bin data/rna/rnac.search data/rna/rnac.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 5 CLASSES with WEIGHTS 22 20 11 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2270.933) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2297.160) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2317.474) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2350.139) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 5 CLASSES with WEIGHTS 22 20 11 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2270.935) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2297.157) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2321.813) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2350.340) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 5 CLASSES with WEIGHTS 22 20 11 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2270.932) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2297.160) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2317.475) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2350.139) N_CLASSES:  2 FOUND ON TRY:   1


;;;-------------------------------------------------------------

;;; MODEL: SINGLE-NORMAL-CN START-FN: BLOCK-SET-CLSF MODEL: -- RNA
;;;             (att-type = real, att-subtype = location)
;;; yes
% autoclass -search data/rna/rnac.db2 data/rna/rnac-location.hd2 data/rna/rnac.model data/rna/rnac-location.s-params

% autoclass -reports data/rna/rnac-location.results-bin data/rna/rnac-location.search data/rna/rnac-location.r-params

% autoclass -predict data/rna/rnac-location-predict.db2 data/rna/rnac-location.results-bin data/rna/rnac-location.search data/rna/rnac-location.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 5 CLASSES with WEIGHTS 23 16 11 10 8
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2514.293) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2532.702) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2546.108) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2559.346) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 5 CLASSES with WEIGHTS 23 16 11 10 8
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2514.343) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2532.458) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2546.141) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2559.150) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 5 CLASSES with WEIGHTS 23 16 11 10 8
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2514.293) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2532.702) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2546.108) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2559.346) N_CLASSES:  2 FOUND ON TRY:   1


;;;-------------------------------------------------------------

;;; MODEL: SINGLE-NORMAL-CM, START-FN: BLOCK-SET-CLSF, MODEL: -- RNA-UNK
;;;                     (att-type = real, att-subtype = scalar) 
;;; yes
% autoclass -search data/rna/rnac-unk.db2 data/rna/rnac.hd2 data/rna/rnac-unk.model data/rna/rnac-unk.s-params

% autoclass -reports data/rna/rnac-unk.results-bin data/rna/rnac-unk.search data/rna/rnac-unk.r-params

% autoclass -predict data/rna/rnac-unk-predict.db2 data/rna/rnac-unk.results-bin data/rna/rnac-unk.search data/rna/rnac-unk.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 5 CLASSES with WEIGHTS 22 21 10 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2315.537) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2343.858) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2345.158) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2359.724) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 5 CLASSES with WEIGHTS 22 21 10 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2315.332) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2343.914) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2345.153) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2359.718) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 5 CLASSES with WEIGHTS 22 21 10 8 7
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-2315.537) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-2343.858) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-2345.158) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-2359.724) N_CLASSES:  2 FOUND ON TRY:   1


;;;-------------------------------------------------------------
;;; MODEL: SINGLE-MULTINOMIAL, START-FN: BLOCK-SET-CLSF, - SOYBEAN == 
;;;                     (att-type = discrete, att-subtype = nominal) 
;;; yes
% autoclass -search data/soybean/soyc.db2 data/soybean/soyc.hd2 data/soybean/soyc.model data/soybean/soyc.s-params

% autoclass -reports data/soybean/soyc.results-bin data/soybean/soyc.search data/soybean/soyc.r-params

% autoclass -predict data/soybean/soyc-predict.db2 data/soybean/soyc.results-bin data/soybean/soyc.search data/soybean/soyc.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 4 CLASSES with WEIGHTS 17 10 10 10
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-645.604) N_CLASSES:  4 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-660.007) N_CLASSES:  5 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-710.824) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-727.858) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 4 CLASSES with WEIGHTS 17 10 10 10
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-645.604) N_CLASSES:  4 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-660.010) N_CLASSES:  5 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-710.824) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-727.858) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 4 CLASSES with WEIGHTS 17 10 10 10
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-645.604) N_CLASSES:  4 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-660.007) N_CLASSES:  5 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-710.824) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-727.858) N_CLASSES:  2 FOUND ON TRY:   1


;;;-------------------------------------------------------------
;;; MODEL: MULTI-NORMAL-CN, START-FN: BLOCK-SET-CLSF, - 3-DIM == 
;;;                   (att-type = real, att-subtype = location)
;;; yes
% autoclass -search data/3-dim/3-dimc.db2 data/3-dim/3-dimc.hd2 data/3-dim/3-dimc.model data/3-dim/3-dimc.s-params

% autoclass -reports data/3-dim/3-dimc.results-bin data/3-dim/3-dimc.search data/3-dim/3-dimc.r-params

% autoclass -predict data/3-dim/3-dimc-predict.db2 data/3-dim/3-dimc.results-bin data/3-dim/3-dimc.search data/3-dim/3-dimc.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 2 CLASSES with WEIGHTS 58 42
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-4255.623) N_CLASSES:  2 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-4257.323) N_CLASSES:  2 FOUND ON TRY:   2 *SAVED*
PROBABILITY: exp(-4257.496) N_CLASSES:  2 FOUND ON TRY:   1
PROBABILITY: exp(-4257.508) N_CLASSES:  2 FOUND ON TRY:   3

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 2 CLASSES with WEIGHTS 50 50
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-4259.769) N_CLASSES:  2 FOUND ON TRY:   1 *SAVED*
PROBABILITY: exp(-4270.297) N_CLASSES:  3 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-4272.345) N_CLASSES:  3 FOUND ON TRY:   4
PROBABILITY: exp(-4274.939) N_CLASSES:  3 FOUND ON TRY:   2

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 2 CLASSES with WEIGHTS 58 42
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-4255.622) N_CLASSES:  2 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-4257.310) N_CLASSES:  2 FOUND ON TRY:   2 *SAVED*
PROBABILITY: exp(-4257.496) N_CLASSES:  2 FOUND ON TRY:   1
PROBABILITY: exp(-4257.508) N_CLASSES:  2 FOUND ON TRY:   3
autoclass -reports data/3-dim/3-dimc.results-bin data/3-dim/3-dimc.search data/3-dim/3-dimc.r-params

;;;-------------------------------------------------------------
;;; MODEL: MULTI-NORMAL-CN, START-FN: BLOCK-SET-CLSF, - GLASS == 
;;;                   (att-type = real, att-subtype = scalar)
;;; yes
% autoclass -search data/glass/glassc.db2 data/glass/glass-3c.hd2 data/glass/glass-mnc.model data/glass/glassc.s-params

% autoclass -reports data/glass/glassc.results-bin data/glass/glassc.search data/glass/glassc.r-params

% autoclass -predict data/glass/glassc-predict.db2 data/glass/glassc.results-bin data/glass/glassc.search data/glass/glassc.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 5 CLASSES with WEIGHTS 97 46 35 19 17
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY  exp(-10897.738) N_CLASSES   5 FOUND ON TRY    3 *SAVED*
PROBABILITY  exp(-11187.745) N_CLASSES   7 FOUND ON TRY    4 *SAVED*
PROBABILITY  exp(-11229.516) N_CLASSES   3 FOUND ON TRY    2
PROBABILITY  exp(-11236.431) N_CLASSES   2 FOUND ON TRY    1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 5 CLASSES with WEIGHTS 100 43 35 19 17
------------------  SUMMARY OF 10 BEST RESULTS  ------------------  
PROBABILITY  exp(-10907.367) N_CLASSES   5 FOUND ON TRY    3 *SAVED*
PROBABILITY  exp(-11187.751) N_CLASSES   7 FOUND ON TRY    4 *SAVED*
PROBABILITY  exp(-11229.554) N_CLASSES   3 FOUND ON TRY    2
PROBABILITY  exp(-11236.418) N_CLASSES   2 FOUND ON TRY    1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 5 CLASSES with WEIGHTS 97 46 35 19 17
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY  exp(-10897.738) N_CLASSES   5 FOUND ON TRY    3 *SAVED*
PROBABILITY  exp(-11187.745) N_CLASSES   7 FOUND ON TRY    4 *SAVED*
PROBABILITY  exp(-11229.516) N_CLASSES   3 FOUND ON TRY    2
PROBABILITY  exp(-11236.432) N_CLASSES   2 FOUND ON TRY    1

;;;-------------------------------------------------------------
;;; MODEL-SINGLE-NORMAL-CM & MODEL-SINGLE-MULTINOMIAL  - IMPORTS-85 
;;; yes
% autoclass -search data/autos/imports-85.db2 data/autos/imports-85.hd2 data/autos/imports-85.model data/autos/imports-85.s-params

% autoclass -reports data/autos/imports-85.results-bin data/autos/imports-85.search data/autos/imports-85.r-params

% autoclass -predict data/autos/imports-85-predict.db2 data/autos/imports-85.results-bin data/autos/imports-85.search data/autos/imports-85.r-params

try_fn_type = "converge_search_3" & rel_delta_range = 0.0025 & n_average = 3
It has 7 CLASSES with WEIGHTS 50 46 37 31 18 13 11
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-16453.536) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-16654.238) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-16816.658) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-17041.867) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_3" & rel_delta_range = 0.05 & n_average = 3
It has 7 CLASSES with WEIGHTS 50 46 40 28 18 13 11
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-16464.989) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-16674.829) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-16816.729) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-17042.456) N_CLASSES:  2 FOUND ON TRY:   1

try_fn_type = "converge_search_4" & cs4_delta_range = 0.0025 & sigma_beta_n_values = 6
It has 7 CLASSES with WEIGHTS 50 46 37 31 18 13 11
------------------  SUMMARY OF 10 BEST RESULTS  ------------------
PROBABILITY: exp(-16453.532) N_CLASSES:  7 FOUND ON TRY:   4 *SAVED*
PROBABILITY: exp(-16654.237) N_CLASSES:  5 FOUND ON TRY:   3 *SAVED*
PROBABILITY: exp(-16816.658) N_CLASSES:  3 FOUND ON TRY:   2
PROBABILITY: exp(-17041.867) N_CLASSES:  2 FOUND ON TRY:   1


;;;-------------------------------------------------------------
;;; MODEL: MULTI-NORMAL-CN. REPORTS CASE - HUNG
;;;             3 MULTI-NORMAL-CN TERMS
;;;                   (att-type = real, att-subtype = scalar)
;;; yes
% autoclass -search data/hung/testsum.db2-bin data/hung/testsum.hd2 data/hung/testsum.model data/hung/testsum.s-params

% autoclass -reports data/hung/testsum.results-bin data/hung/testsum.search data/hung/testsum.r-params

;;; ordering & non-ordering of attributes in influence values report
order_attributes_by_influence_p = true
order_attributes_by_influence_p = false


;;;-------------------------------------------------------------
;;; MODEL: SINGLE_MULTINOMIAL. REPORTS CASE - ROMKE
;;;             LARGE NUMBER OF DISCRETE ATTRIBUTES
;;;                   (att-type = discrete, att-subtype = nominal)
;;; yes
% autoclass -reports data/romke/big.results data/romke/big.search data/romke/big.r-params




