({

	init: function(cmp, event, helper) {
        helper.setColumns(cmp);
        helper.setDataForFilter(cmp);
        //helper.fetchNotes(cmp, event);
		helper.setDataForDataTable(cmp, event);

    },

    loadMoreData : function(cmp, event, helper) {
            if(!cmp.get('v.filterIsUse') && !cmp.get('v.infinitiScrollCheck')){
                event.getSource().set("v.isLoading", true);   
                cmp.set('v.loadMoreStatus', 'Loading');
                helper.fetchNotes(cmp, event, cmp.get('v.dataNotes').length);
            }
    },
    setDataFilter: function(cmp, event, helper) {
        cmp.set('v.filterIsUse', true);
        helper.getDataFromFilter(cmp);
    },

    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },
    exportToExcel:function(cmp, event, helper) {
        cmp.set('v.isLoading', true);
        var stockData = cmp.get("v.dataNotes");
        console.log('stockData : ', stockData)
        var csv = helper.onLoad(cmp,stockData);   
        if (csv == null){return;} 

        let blob = new Blob([csv]);
        
        if (window.navigator.msSaveOrOpenBlob){
             window.navigator.msSaveBlob(blob, "ExportCsvFile.csv");
        } else {
             let hiddenElement = document.createElement('a');
             hiddenElement.href = window.URL.createObjectURL(blob, {
                type: "text/plain"
             });
             hiddenElement.download = "ExportCsvFile.csv";
             document.body.appendChild(hiddenElement);
             hiddenElement.click();
             document.body.removeChild(hiddenElement);
         }
        cmp.set('v.isLoading', false);
    },
    
    openModal: function(cmp, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      let isOpen = cmp.get("v.isOpen");
        
        let cmpTarget = cmp.find('changeIt');
        if(!isOpen){
               $A.util.removeClass(cmpTarget, 'myTableAllWidth');
               $A.util.addClass(cmpTarget, 'myTable');
        } 
        if(isOpen){
            $A.util.removeClass(cmpTarget, 'myTable');
            $A.util.addClass(cmpTarget, 'myTableAllWidth');
        }

      cmp.set("v.isOpen", !isOpen);
   },
    
    resetFilter: function(cmp, event, helper){
        helper.resetFilterToNull(cmp, event);
    }

})