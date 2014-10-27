/**
########################################################################
#  File Name       : CreateDefaultHistory 
#  Author          : Ceptes Software Pvt. Ltd.
#  Created Date    : 11th March 2014
#  Description     : Create default history records after create/update the credit detail records according to the status
#
#
#  Copyright (c) Caribbean Credit Bureau Ltd. All Rights Reserved.
#  Permission to use, copy, modify, and distribute this software and its documentation
#  for any commercial purpose, without fee, and without a written agreement from CCB Ltd.,
#  is hereby forbidden.
#
#  Any modification to source code, must include this paragraph and copyright. 
#
#  Permission is not granted to anyone to use this software for commercial uses.
#
#  Company Url : http://carribbeancreditbureau.com
########################################################################
*/  

trigger CreateDefaultHistory on Credit_Detail__c(After Insert,After Update){
Map<String,String> defaultDTOCMap = new Map<String,String>{'Default' => 'D','Payment Arrangement' => 'P','Resolved' => 'R'};
Map<String,String> defaultURRMap = new Map<String,String>{'Write-off' => 'w','Collection agency' => 'c','Payment Arrangement' => 'p','Noncompliance with Payment Arrangement' => 'n','Settled by Arrangement' => 's','Refinanced' => 'r','Full Payment' => 'f'};
List<Default_History__c> dhList = new List<Default_History__c>();
    
    if(Trigger.isInsert){
        for(Credit_Detail__c  crd : Trigger.new){
            if(crd.Default_Status__c == 'Default')
                dhList.add(getDefaultHistory(crd));
        }
        
        if(dhList.size() > 0){
            try{
                Insert dhList;
            }catch(DmlException de){System.debug('---Error while inserting default histry----'+de);}
        }
    }
    
    if(Trigger.isUpdate){
        for(Credit_Detail__c  crd : Trigger.new){
            if(Trigger.newMap.get(crd.Id).Default_Status__c != 'Current' && Trigger.newMap.get(crd.Id).Default_Status__c != 'Possibly Default' && Trigger.newMap.get(crd.Id).Default_Status__c != Trigger.oldMap.get(crd.Id).Default_Status__c) 
                dhList.add(getDefaultHistory(crd));           
        }
        
        if(dhList.size() > 0){
            try{
                Insert dhList;
            }catch(DmlException de){System.debug('---Error while inserting default histry----'+de);}
        }
    }  
    
    
    //Description   : Construct a new Default History  object
    //Input         : Credit_Detail__c 
    //Output        : Credit_Detail__c 
    
    private Default_History__c getDefaultHistory(Credit_Detail__c crd){
        Default_History__c dHistory = new Default_History__c(
           // As_of_Date__c = crd.Default_Report_Date__c != null ? crd.Default_Report_Date__c : (crd.Default_Status__c == 'Default' ?  crd.Default_as_of_Date__c : crd.Default_Status__c == 'Resolved' ? crd.Resolved_AsOf_Date__c : null),
            As_of_Date__c = crd.Default_Report_Date__c,
            Credit_Detail__c = crd.Id,
            Default_State__c = defaultDTOCMap.get(crd.Default_Status__c),
            Comments__c = crd.Default_Flag_Reason_Observation__c != null ? (crd.Default_Flag_Reason_Observation__c.length() > 255 ? crd.Default_Flag_Reason_Observation__c.subString(0,255) : crd.Default_Flag_Reason_Observation__c ): null,
            Report_Date__c = System.Today(),
            Situtaion__c = crd.Default_Unresolved_Reason__c != null ? defaultURRMap.get(crd.Default_Unresolved_Reason__c) : null);
        return dHistory;
    } 
}