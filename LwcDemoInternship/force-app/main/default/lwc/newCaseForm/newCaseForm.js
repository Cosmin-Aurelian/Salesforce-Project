import { LightningElement, track, wire, api } from 'lwc';
import insertCase from '@salesforce/apex/NewCaseFormController.insertCase';
import getPickListValuesByRecordTypeId from '@salesforce/apex/NewCaseFormController.getPickListValuesByRecordTypeId';
import ACCOUNT_ID from '@salesforce/schema/User.ContactId';
import USER_ID from '@salesforce/user/Id';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';


export default class NewCase extends LightningElement {
    caseRecordType = '';
    priorityPickList = '';
    @track insertRecordType = true;
    @track insertPhoto = true;
    @track insertAmount = true;
    userInput = {};
    @track pickValues = [];

    @wire(getRecord, {recordId: USER_ID, fields: [ACCOUNT_ID]})
    user;

    get accountId(){
        return getFieldValue(this.user.data, ACCOUNT_ID);
    }

    @api
    myRecordId;
 
    get acceptedFormats() {
        return ['.pdf', '.png', '.txt'];
    }

    goBackToTrue(event){
        this.insertRecordType = true;
    }
 
    handleUploadFinished(event) {
        this.documentId = event.detail.files[0].documentId;
        console.log(this.documentId);
    }

    get returnPriorityPickList(){
        return [
            { label: 'Low', value: 'Low' },
            { label: 'Medium', value: 'Medium' },
            { label: 'High', value: 'High' },
        ];
    }

    get recordTypes() {
        return [
            { label: 'Maintenance', value: 'MaintenanceRecordType' },
            { label: 'Administration', value: 'AdministrationRecordType' },
            { label: 'Improvements', value: 'ImprovementsRecordType' },
        ];
    }
    moveToCaseDescription(event){
        this.insertRecordType = false;
        if (this.userInput["recordType"] == 'AdministrationRecordType')
        {
            this.insertPhoto = false;
            this.insertAmount = true;
        }else if(this.userInput["recordType"] == 'ImprovementsRecordType'){
            this.insertAmount = false;
            this.insertPhoto = true;
        }else if(this.userInput["recordType"] == 'MaintenanceRecordType'){
            this.insertAmount = true;
            this.insertPhoto = true;
        }
        
        this.userInput[event.target.dataset.key] = event.target.value;
        getPickListValuesByRecordTypeId({
            recordTypeParameter: this.userInput["recordType"]
        }).then(
            (resultedValues)=>{
                console.log(resultedValues);
                let mapData = [];
                for(let key in resultedValues){
                    mapData.push({label: key, value: resultedValues[key]})
                }
                this.pickValues = mapData;
            }).catch()
    }

    handleChange(event){
        this.userInput[event.target.dataset.key]= event.target.value;
        console.log(JSON.stringify(this.userInput));

    }

    submitFormData(event){
        insertCase({
            recordType: this.userInput["recordType"],
            emailParam: this.userInput["emailInput"],
            description: this.userInput["description"],
            subject: this.userInput["subject"],
            priority: this.userInput["priorityInput"],
            typeReason: this.userInput["reasonInput"],
            accountId: this.accountId,
            amount: this.userInput["estimatedAmountInput"],
            documentIdParameter: this.documentId,
            
        }).then(
            (returnedResult)=>{
                let communityUrl ='https://cosmindemo-developer-edition.eu40.force.com/demo/s/detail/';
                window.open(communityUrl + returnedResult, '_top');
                console.log("Succes");
            }
        ).catch((error)=> {console.log(JSON.stringify(error));
        });
    }

    
}