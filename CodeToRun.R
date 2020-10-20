#This file is to support a study during design stage
#This use case needs to know different HDL and total cholesterol units

#We assume a site has executed latest version of Achilles
#if you do not have Achilles results, uncomment and execute a ACHILLES_PART below


#The setup is EXACTLY the same as for the prediction package, taken from 
#https://github.com/ohdsi-studies/RCRI/blob/master/extras/CodeToRun.R
#just the top few lines, cut and paste it from your prior executions


# USER INPUTS
#=======================
#this is the only special parameter in addition to what RCRI package has
#pick some generic name (site4563) if you want to remain somewhat hidden
siteName='MySiteName'

# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'


# Add a database with read/write access as this is where the cohorts will be generated
# THIS SCHEMA HAS YOUR ACHILLES RESULTS
cohortDatabaseSchema <- 'work database schema'






#second user input (optional is to specify concepts of interest)
#enumerate them below or fetch them from the internet
valueSet=c(2212449, 3003767, 3007070, 3007676, 3011884, 3013473, 3015204, 
           3016945, 3022449, 3023602, 3023752, 3024401, 3030792, 3032771, 
           3033638, 3034482, 3040815, 3053286, 4005504, 4008127, 4011133, 
           4019543, 4041557, 4041720, 4042059, 4042081, 4055665, 4076704, 
           4101713, 4195503, 4198116, 37208659, 37208661, 37392562, 37392938, 
           37394092, 37394229, 37394230, 37398699, 40757503, 40765014, 44789188, 
           45768617, 45768651, 45768652, 45768653, 45768654, 45771001, 45772902
)

#or fetch them from internet
library(readr)
url='https://raw.githubusercontent.com/ohdsi-studies/PCE/master/inst/settings/HDL-C_mgdL_concepts.csv'
inetSet=read_csv(url)

#uncoment this line to update it at later time, (or update even the URL)
#valueSet=inetSet$x

#=======================








#end of user input and start of main code



resultsDatabaseSchema<-cohortDatabaseSchema  #just renaming for convenience


#ACHILLES_PART

  # Achilles::achilles(connectionDetails = connectionDetails
  #                    ,cdmDatabaseSchema = cdmDatabaseSchema
  #                    ,resultsDatabaseSchema = resultsDatabaseSchema
  #                    ,cdmVersion = '5.3'
  #                    ,analysisIds = c(1807)
  #                    ,runHeel = FALSE
  #                    ,createIndices = FALSE
  #                    ,verboseMode = TRUE)

#next we fetch Achilles measure and filter only some measurements

#From this overview, https://github.com/OHDSI/Achilles/blob/master/inst/csv/achilles/achilles_analysis_details.csv
#we need analysis 1807

units<-Achilles::fetchAchillesAnalysisResults(connectionDetails = connectionDetails,
                                       resultsDatabaseSchema = resultsDatabaseSchema,
                                       analysisId = 1807)

#some manipulation
  units2<-units$analysisResults
  names(units2) <- tolower(names(units2))
  units2$measurement_concept_id <-as.integer(units2$measurement_concept_id)
  units2$unit_concept_id <-as.integer(units2$unit_concept_id)


#filter only concepts of interest

units2 %>% dplyr::filter(measurement_concept_id %in% valueSet)




#writing outputs
readr::write_csv(units2,path = paste0('AdHocDiag-',siteName,'.csv'))


#inspect the output 
#and share by email this output file 
#AdHocDiag-xxxx.csv with the study coordinator