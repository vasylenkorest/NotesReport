({
	COLUMNS: [
        { label: 'Object Name', fieldName: 'Object Name', type: 'text', sortable: true, cellAttributes: { alignment: 'left' }},
        {label: 'Record Name',
                  fieldName: 'parentLink',
                  type: 'url',
         		  sortable: true, 
         		  cellAttributes: { alignment: 'left' },
                  typeAttributes: {
                    label: { fieldName: 'Record Name' }}},
        {label: 'File Name',
                  fieldName: 'linkTitle',
                  type: 'url',
          	      sortable: true, 
         		  cellAttributes: { alignment: 'left' },
                  typeAttributes: {
                      label: { fieldName: 'File Name' }}},
        { label: 'Notes Content', fieldName: 'Notes Content', sortable: true, cellAttributes: { alignment: 'left' }},
        { label: 'Published Date', fieldName: 'Published Date', type: 'date', sortable: true, cellAttributes: { alignment: 'left' }},
        {label: 'Created By',
                  fieldName: 'CreatedByLink',
                  type: 'url',
         		  sortable: true, 
         		  cellAttributes: { alignment: 'left' },
                  typeAttributes: {
                      label: { fieldName: 'Created By' }}},
        { label: 'Last Revised Date', fieldName: 'Last Revised Date', type: 'date', sortable: true, cellAttributes: { alignment: 'left' }},
        {label: 'Last Revised By',
                  fieldName: 'LastModifiedDateById',
                  type: 'url',
         		  sortable: true, 
         		  cellAttributes: { alignment: 'left' },
                  typeAttributes: {
                    label: { fieldName: 'Last Revised By' }}}
    ],
    
    DATA: [],
    
    setColumns: function(cmp) {
        cmp.set('v.columns', this.COLUMNS);
    },
    
    setData: function(cmp, data){
        
                let massData = [];
                
                let fileIdRelatedMap = new Map();
        
                let relatedArrayNoSObject = [];

               for (const [key, value] of Object.entries(data)) {
                  //console.log(`${key}: ${value}`);
                   
					for (const element of value) {
                      //console.log(element);
                        
                        if(!Object.keys(element).includes('ContentDocumentLinks')){
                            
                        		let row = {};  
                                
                                    row['Object Name'] = key;
                            
                            		row['linkTitle'] = '/' + element.Id;

                                    row['File Name'] = element.Title;
                              
                                    row['Created By'] = element.CreatedBy.Name;
                                    row['CreatedByLink'] = '/' + element.CreatedBy.Id;
                                    
                                    row['Last Revised By'] = element.LastModifiedBy.Name;
                                    row['LastModifiedDateById'] = element.LastModifiedBy.Id;
                                                                 
                                    row['Published Date'] = element.CreatedDate;
                                    
                                    row['Last Revised Date'] = element.LastViewedDate;
                                
                                        if(element.ContentVersions != undefined) {
                                           element.ContentVersions.forEach(value => {
                                                row['Notes Content'] = value.TextPreview;
                                            });
                                        }
        
                                    relatedArrayNoSObject.push(row); 

                        } else {
                        
                            if(fileIdRelatedMap.has(element.ContentDocumentLinks[0].ContentDocumentId)) {
                                    continue;
                            }
                        
						let relatedArray = [];
                            
                            element.ContentDocumentLinks.forEach(value => {
                                if(!value.LinkedEntity.Id.startsWith('005')){
    
                                    let row = {};                    
                                    row['Record Name'] = value.LinkedEntity.Name;
                                
                                    row['parentLink'] = '/' + value.LinkedEntityId;
                                
                                    row['linkTitle'] = '/' + value.ContentDocumentId;
                                
                                    row['Object Name'] = key;
                                    
                                    row['File Name'] = element.Title;
                              
                                    row['Created By'] = element.CreatedBy.Name;
                                    row['CreatedByLink'] = '/' + element.CreatedBy.Id;
                                    
                                    row['Last Revised By'] = element.LastModifiedBy.Name;
                                    row['LastModifiedDateById'] = element.LastModifiedBy.Id;
                                                                 
                                    row['Published Date'] = element.CreatedDate;
                                    
                                    row['Last Revised Date'] = element.LastViewedDate;
                                
                                        if(element.ContentVersions != undefined) {
                                           element.ContentVersions.forEach(val => {
                                                row['Notes Content'] = val.TextPreview;
                                            });
                                        }
        
                                    relatedArray.push(row);
                                 }
                            });
                                               
                            fileIdRelatedMap.set(element.ContentDocumentLinks[0].ContentDocumentId, relatedArray);  
                        } 
                    }
				}

                fileIdRelatedMap.set('_blank', relatedArrayNoSObject); 
                                               
                massData.push(...fileIdRelatedMap.values());
                          
                this.DATA.push(massData.flat()); 
                                   
                //console.log(massData.flat());

                return massData.flat();
      
    },
    
    
    fetchNotes : function(cmp, event, offSetCount) {
  
        var action = cmp.get("c.notesListUpdate");
        action.setParams({
            
            "intOffSet" : offSetCount
            
        });
        
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                
                //console.log('data FETCH : ', data);

                if(Object.keys(data).length != 0){
                    
                    cmp.set('v.infinitiScrollCheck', Object.values(data).flat().length < 49);
                    
                    let currentData = cmp.get('v.dataNotes');
            		cmp.set("v.dataNotes", currentData.concat(this.setData(cmp, data)));
                    
                } else {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "No Records!",
                            "message": "No Notes found!"
                        });
                        toastEvent.fire();
                }
                                  
            }
         event.getSource().set("v.isLoading", false);
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    setDataForFilter: function(cmp){

		let action = cmp.get("c.getAllDataForFilter");

    	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                
                //console.log('data For Filter : ', data);
				
                let listsObjectName = [];
                let listRecordName = [];
                let listCreatedByUsers = [];
                let listRevisedByUsers = [];
                if(data.length != 0){
                    
                    data[0].sort().forEach(el => {
                        listsObjectName.push({'label': el, 'value': el})
                    })
                    cmp.set('v.chosesObject', listsObjectName);
                
                	data[1].sort().forEach(el => {
                        listRecordName.push({'label': el, 'value': el})
                    })
               		cmp.set('v.filterByRecordName', listRecordName);
            
                    data[2].sort().forEach(el => {
                        listCreatedByUsers.push({'label': el, 'value': el})
                    })
                    cmp.set('v.createdBy', listCreatedByUsers);
            
                	data[3].sort().forEach(el => {
                        listRevisedByUsers.push({'label': el, 'value': el})
                    })
                    cmp.set('v.lastRevisedBy', listRevisedByUsers);
                }

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

	getDataFromFilter: function(cmp, event) {
        
		let action = cmp.get("c.forDataByFilterCriteria");
        let from = cmp.find('FromPublishedDate').get('v.value');
        let to = cmp.find('ToPublishedDate').get('v.value');
        let fromlrd = cmp.find('FromLastRevisedDate').get('v.value');
        let tolrd = cmp.find('ToLastRevisedDate').get('v.value');
        let createdBy =  cmp.find('CreatedBy').get('v.value');
        let lastRevisedBy = cmp.find('lastRevisedBy').get('v.value');
        let keyWordNC = cmp.find('keyWordNC').get('v.value');
        let filterByRecordName = cmp.find('filterByRecordName').get('v.value');
        let filterBychosesObject = cmp.find('filterBychosesObject').get('v.value');
        
        action.setParams({
            fromPublishDate: from ? new Date(from) : null,
            toPublishDate: to ? new Date(to) : null,
            fromRevisedDate: fromlrd ? new Date(fromlrd) : null,
            toRevisedDate: tolrd ? new Date(tolrd) : null,
            createdByName: createdBy ? createdBy : null,
            lastRevisedBy: lastRevisedBy ? lastRevisedBy : null,
            filterByRecordName: filterByRecordName ? filterByRecordName : null,
            sObjectNameFilter: filterBychosesObject ? filterBychosesObject : null,
            keyWordNC: keyWordNC ? keyWordNC : null
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                
                console.log('getDataFromFilter : ', data);
                
                cmp.set('v.dataNotes', this.setData(cmp, data));

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

        
        
    },
    setDataForDataTable: function(cmp, event){
        if(!cmp.get('v.filterIsUse')){
            cmp.set('v.filterIsUse', false);
            this.fetchNotes(cmp, event, 0);
        } else {
            this.getDataFromFilter(cmp);
        }
    },

    resetFilterToNull: function(cmp, event){
            cmp.find('FromPublishedDate').set('v.value', null);
            cmp.find('ToPublishedDate').set('v.value', null);
            
            cmp.find('FromLastRevisedDate').set('v.value', null);
            cmp.find('ToLastRevisedDate').set('v.value', null);
            
            cmp.find('CreatedBy').set('v.value', null);
            cmp.find('lastRevisedBy').set('v.value', null);
        
        	cmp.find('keyWordNC').set('v.value', null);
       		cmp.find('filterByRecordName').set('v.value', null);
        
        	cmp.find('filterBychosesObject').set('v.value', null);
	        if(cmp.get('v.filterIsUse')){
                cmp.set('v.infinitiScrollCheck', false);
                cmp.set('v.filterIsUse', false);
                event.getSource().set("v.isLoading", true);
                cmp.set('v.dataNotes', []);
                this.fetchNotes(cmp, event, 0);
        	}
    },
      

    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = this.DATA.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },
        
    onLoad : function(cmp, objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Object Name', 'Record Name','File Name', 'Notes Content', 'Published Date', 'Created By','Last Revised Date','Last Revised By'];
            
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                if(objectRecords[i][skey] == undefined) {
                    csvStringResult += '';
                } else {
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }
                
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        if(csvStringResult){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "The csv file has been downloaded successfully."
            });
            toastEvent.fire();
        }
        // return the CSV formate String 
        return csvStringResult;        
    },
})