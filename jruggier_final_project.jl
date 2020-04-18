
# load packages
using DataFrames
using CSV
using Missings

# ADMISSIONS dataframe
a_df = CSV.File("/Users/jakeruggiero/methods2020/work-files-2020-jruggier/final_project/ADMISSIONS_info.csv"; 
select=[:SUBJECT_ID, :ADMITTIME, :DISCHTIME, :DEATHTIME, :INSURANCE, :LANGUAGE, :RELIGION, :MARITAL_STATUS, :ETHNICITY, :HOSPITAL_EXPIRE_FLAG],
 header = 1, footerskip = 0) |> DataFrame

# DIAGNOSES dataframe
d_df = CSV.File("/Users/jakeruggiero/methods2020/work-files-2020-jruggier/final_project/DIAGNOSES_ICD_info.csv"; 
select=[:SUBJECT_ID, :ICD9_CODE], header = 1, footerskip = 0) |> DataFrame 

# PATIENTS dataframe
p_df =  CSV.File("/Users/jakeruggiero/methods2020/work-files-2020-jruggier/final_project/PATIENTS_info.csv";
select=[:SUBJECT_ID, :GENDER, :DOB], header = 1, footerskip = 0) |> DataFrame  

# ICUSTAYS dataframe
i_df =  CSV.File("/Users/jakeruggiero/methods2020/work-files-2020-jruggier/final_project/ICUSTAYS_info.csv"; 
select=[:SUBJECT_ID, :LOS], header = 1, footerskip = 0) |> DataFrame 

# ALL DATA
df = join(a_df, d_df, p_df, i_df, on = :SUBJECT_ID)   

# Handles the missing data in ICD9_CODES, allows for sorting into 3 major groups
replace!(df.ICD9_CODE, missing => "0")
disallowmissing!(df, :ICD9_CODE)

# Fixes some random error in sorting deaths and survived using the HOSPITAL_EXPIRE_FLAG
replace!(df.HOSPITAL_EXPIRE_FLAG, 0 => 10)

# Groupings by obesity status
obese_df = df[df.ICD9_CODE .== "27800", :]
morbidly_obese_df = df[df.ICD9_CODE .== "27801", :]
healthy_df = df[(df.ICD9_CODE .!= "27800") .& (df.ICD9_CODE .!= "27801"), :]

# Groupings by obesity status - deaths
# obese_df_deaths = obese_df[obese_df.HOSPITAL_EXPIRE_FLAG .= 1, :]
# morbidly_obese_df_deaths = morbidly_obese_df[morbidly_obese_df.HOSPITAL_EXPIRE_FLAG .= 1, :]
# healthy_df_deaths = healthy_df[healthy_df.HOSPITAL_EXPIRE_FLAG .= 1, :]

# attempt #2 - healthy_df_deaths isn't working
obese_df_deaths = df[(df.ICD9_CODE .== "27800") .& (0.5 .< df.HOSPITAL_EXPIRE_FLAG .< 1.5), :]
morbidly_obese_df_deaths = df[(df.ICD9_CODE .== "27801") .& (0.5 .< df.HOSPITAL_EXPIRE_FLAG .< 1.5), :]
healthy_df_deaths = df[(df.ICD9_CODE .!= "27800") .& (df.ICD9CODE .!= "27801") .& (0.5 .< df.HOSPITAL_EXPIRE_FLAG .< 1.5), :]

# Groupings by obesity status - survived
# obese_df_alive = obese_df[obese_df.HOSPITAL_EXPIRE_FLAG .= 10, :]
# morbidly_obese_df_alive = morbidly_obese_df[morbidly_obese_df.HOSPITAL_EXPIRE_FLAG .= 10, :]
# healthy_df_alive = healthy_df[healthy_df.HOSPITAL_EXPIRE_FLAG .= 10, :]

#attempt #2 - healthy_df_alive isn't working
obese_df_alive = df[(df.ICD9_CODE .== "27800") .& (9 .< df.HOSPITAL_EXPIRE_FLAG .< 11), :]
morbidly_obese_df_alive = df[(df.ICD9_CODE .== "27801") .& (9 .< df.HOSPITAL_EXPIRE_FLAG .< 11), :]
healthy_df_alive = df[(df.ICD9_CODE .!= "27800") .& (df.ICD9_CODE .!= "27801") .& (9 .< df.HOSPITAL_EXPIRE_FLAG .< 11), :]

# Groupings, interchange as needed
df_grouped = groupby(obese_df_alive, :SUBJECT_ID ; sort=true)
df_grouped = groupby(morbidly_obese_df_alive, :SUBJECT_ID ; sort=true)
df_grouped = groupby(healthy_df_alive, :SUBJECT_ID ; sort=true)