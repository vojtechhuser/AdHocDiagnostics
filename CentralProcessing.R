library(tidyverse);library(magrittr)
load('p:/human/o/athena/concept.rda')

setwd('c:/net')
ofiles <- list.files(path = getwd(), pattern = 'AdHocDiag*', full.names = TRUE)
ofiles

ll=map(ofiles,read_csv)
ll<-map(ll,~{names(.x)<-tolower(names(.x));return(.x)})
ll2<-map2(ll,basename(ofiles),~mutate(.x,site=.y))
d<-bind_rows(ll2)



#expand
names(d)
d2<-d  %>% 
  filter(measurement_concept_id != 0) %>% 
  #filter(stratum2_id != 0) %>% 
  left_join(concept %>% select(concept_id,concept_name,concept_code)
            ,by=c('measurement_concept_id'='concept_id')) %>%
  left_join(concept %>% select(concept_id,concept_name)
            ,by=c('unit_concept_id'='concept_id'))


names(d2)

d2 %<>% arrange(site,measurement_concept_id,desc(count_value))
d2 %<>% group_by(measurement_concept_id,site) %>% mutate(site_ratio=count_value/sum(count_value))
d2 %<>% group_by(measurement_concept_id,unit_concept_id) %>% mutate(network_ratio=count_value/sum(count_value))


d2 %>% write_csv('ah-d2.csv')


sites= d2 %>% count(site)

tests= d2 %>% count(measurement_concept_id)
names(d2)
helper = d2 %>% ungroup() %>% select(measurement_concept_id,concept_name.x,site) %>%
  distinct() 

testsSiteCnt=helper %>% group_by(measurement_concept_id,concept_name.x) %>% 
  summarize(site_cnt=n()
            ,sites=paste(site,collapse = '|')
  )


testsNtwCnt=d2 %>% group_by(measurement_concept_id) %>% 
  summarise(network_sum_count_value=sum(count_value)) 

# testsFiltered=tests %>% filter(site_cnt>1) %>% left_join(testsNtwCnt)
# testsFiltered %>% write_csv('ah-testsFiltered.csv')


options(scipen=999) #disable scientific notation



tuPairs=d2 %>% group_by(measurement_concept_id,unit_concept_id) 

tuPairsCnt=d2 %>% group_by(measurement_concept_id,unit_concept_id,site) %>% mutate(site_ratio=count_value/sum(count)) 
  site_cnt=n())
tuSubset=tuPairs %>% filter(site_cnt>=2)

names(d2)

tOverview=d2 %>% arrange(measurement_concept_id,desc(count_value)) %>% 
group_by(measurement_concept_id,concept_name.x) %>% 
  summarize(n=n()
            ,unit_names=paste(concept_name.y,collapse = '|')
            ,units_cids=paste(unit_concept_id,collapse = '|')) 
tOverview %>% left_join(testsSiteCnt)


tOverview %<>%   filter(n>1)

tOverviewExt=tOverview %>% left_join(tests) %>%
  left_join(testsNtwCnt) %>% 
  arrange(desc(site_cnt),desc(network_sum_count_value),measurement_concept_id)
names(tOverviewExt)

tOverviewExt  %>% write_csv('ah-tOverviewExt.csv')
