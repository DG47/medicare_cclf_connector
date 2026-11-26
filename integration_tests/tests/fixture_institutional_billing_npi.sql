{{ config(tags=['fixture']) }}

/*
    CCLF1 carries the billing provider of each Part A claim in
    CLM_BLG_PRVDR_NPI_NUM (Claim Billing Provider NPI Number, IP v43 Table 2).
    Every institutional medical_claim row must carry it as billing_npi, as the
    DME rows carry PAYTO_PRVDR_NPI_NUM. facility_npi stays FAC_PRVDR_NPI_NUM.
*/

select distinct
      medical_claim.claim_id
    , medical_claim.claim_line_number
    , medical_claim.billing_npi
    , parta_claims_header.clm_blg_prvdr_npi_num
from {{ ref('medical_claim') }} as medical_claim
inner join {{ ref('parta_claims_header') }} as parta_claims_header
    on medical_claim.claim_id = parta_claims_header.cur_clm_uniq_id
where medical_claim.claim_type = 'institutional'
  and nullif(trim(parta_claims_header.clm_blg_prvdr_npi_num), '') is not null
  and trim(parta_claims_header.clm_blg_prvdr_npi_num) <> '~'
  and coalesce(medical_claim.billing_npi, '') <> trim(parta_claims_header.clm_blg_prvdr_npi_num)
