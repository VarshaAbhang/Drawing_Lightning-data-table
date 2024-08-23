import { LightningElement, api, wire, track } from 'lwc';
import getDrawingNumberData from '@salesforce/apex/DrawingNumberController.getDrawingNumberData';
import getDNLIdata from '@salesforce/apex/DrawingNumberController.getDNLIdata';
import getDimensiondata from '@salesforce/apex/DrawingNumberController.getDimensiondata';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import CustomDataTypes from 'c/customDataTypes';

const actions = [
    {label: 'View', name: 'view'},
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];


const Drawing_Number_columns = [
    { 
        label: 'Assembly Drawing',
        type: 'customAssembly', 
        typeAttributes: { 
            AssemblyDrawing: { fieldName: 'Drawing_Code1__r.Drawing__r.Assebly_Drawing__c' }   
        },
        cellAttributes: { alignment: 'center' }
    },
    { 
        label: 'Cut View Drawing',
        type: 'customCutView', 
        typeAttributes: { 
            CutViewDrawing: { fieldName: 'Drawing_Code1__r.Drawing__r.Cut_View_Drawing__c' }   
        },
        cellAttributes: { alignment: 'center' }
    },
    { 
        label: 'Drawing Image',
        type: 'customDrawing', 
        typeAttributes: { 
            drawingImage: { fieldName: 'Drawing_Code1__r.Drawing__r.Drawing_Image__c' }   
        },
        cellAttributes: { alignment: 'center' }
    }
];

const DN_LI_columns = [
     
    { label: 'Name', fieldName: 'Name' },
    { label: 'Drawing Number', fieldName: 'Drawing_Number__r.Name' },
    { label: 'Item Family', fieldName: 'Item_Family__c' },
    { label: 'Item Category', fieldName: 'Item_Category__c' },
    { label: 'Part Number', fieldName: 'Part_Number__c' },
    { label: 'Part Name', fieldName: 'Part_name__r.Name' },
    {
        label: 'Part Drawing Number',
        fieldName: 'Part_Drawing_Number__r.Name',
        editable: true
    }
    
];


const DIMENSIONS_COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Size', fieldName: 'Size__c', type: 'text', editable: true },
    { label: 'Tolerance Plus', fieldName: 'Tolerance_Plus__c', type: 'number', editable: true },
    { label: 'Tolerance Minus', fieldName: 'Tolerance_Minus__c', type: 'number', editable: true },
    { label: 'Drawing Number Name', fieldName: 'Drawing_Number__r.Name', type: 'text' },
    { label: 'Drawing Name', fieldName: 'Drawing__r.Name', type: 'text' },
    { label: 'Record Type', fieldName: 'RecordType.Name', type: 'text' },
    { label: 'Remarks', fieldName: 'Remarks__c', type: 'text', editable: true },
    {
        type: 'action', typeAttributes : { rowActions: actions }
        
    }
];

export default class DrawingNumberDataTable extends LightningElement {
    @api recordId;
    @track drawingNumberdata = [];
    @track dnLiRecords = [];
    @track dimensionRecords = [];
    @track draftValues = [];
    @track selectedRowIds = []; 

    wiredDNLiResult;

    DN_LI_columns = DN_LI_columns;
    DIMENSIONS_COLUMNS = DIMENSIONS_COLUMNS;
    Drawing_Number_columns = Drawing_Number_columns;

    @wire(getDrawingNumberData, { drawingNumberId: '$recordId' })
    wiredDrawingNumberData({ error, data }) {
        if (data) {
            if (Array.isArray(data)) {
                this.drawingNumberdata = data.map((item, index) => ({
                    ...item,
                    'Drawing_Code1__r.Drawing__r.Assebly_Drawing__c': data.Drawing_Code1__r?.Drawing__r?.Assebly_Drawing__c || '',
                    'Drawing_Code1__r.Drawing__r.Cut_View_Drawing__c': data.Drawing_Code1__r?.Drawing__r?.Cut_View_Drawing__c || '',
                    'Drawing_Code1__r.Drawing__r.Drawing_Image__c': data.Drawing_Code1__r?.Drawing__r?.Drawing_Image__c || '',
                    rowNumber: index + 1
                }));
                
            } else {
                this.drawingNumberdata = [{
                    ...data,
                    'Drawing_Code1__r.Drawing__r.Assebly_Drawing__c': data.Drawing_Code1__r?.Drawing__r?.Assebly_Drawing__c || '',
                    'Drawing_Code1__r.Drawing__r.Cut_View_Drawing__c': data.Drawing_Code1__r?.Drawing__r?.Cut_View_Drawing__c || '',
                    'Drawing_Code1__r.Drawing__r.Drawing_Image__c': data.Drawing_Code1__r?.Drawing__r?.Drawing_Image__c || '',
                    rowNumber: 1
                }];
                console.log('Drawing Number Data:', JSON.stringify(this.drawingNumberdata, null, 2));
            }
        } else if (error) {
            console.error('Error fetching drawingNumber data', error);
        }
    }

    @wire(getDNLIdata, { drawingNumberId: '$recordId' })
    getwiredDNLIdata(result) {
        this.wiredDNLiResult = result;
        const { error, data } = result;
        if (data) {
            this.dnLiRecords = data.map((item, index) => ({
                ...item,
                'Drawing_Number__r.Name': item.Drawing_Number__r?.Name || '',
                'Part_name__r.Name': item.Part_name__r?.Name || '',
                'Part_Drawing_Number__r.Name': item.Part_Drawing_Number__r?.Name || '',
                rowNumber: index + 1
            }));
            console.log('Fetched DNLI data', data);
        } else if (error) {
            console.error('Error fetching DN_LI data', error);
        }
    }
    @wire(getDimensiondata, { drawingNumberId: '$recordId' })
    getwiredDimensionData(result) {
        this.wiredDimensionDataResult = result;
        const { error, data } = result;
        if (data) {
            console.log('Fetched Dimension data', data); // Log data
            this.dimensionRecords = data.map((item, index) => ({
                ...item,
                'Drawing_Number__r.Name': item.Drawing_Number__r?.Name || '',
                'Drawing__r.Name': item.Drawing__r?.Name || '',
                'RecordType.Name': item.RecordType?.Name || '',
                rowNumber: index + 1
            }));
        } else if (error) {
            console.error('Error fetching dimension data', error);
        }
    }

        async handleDnLiCellChange(event) {
            const updatedFields = event.detail.draftValues;
            const updatePromises = updatedFields.map(record => {
                const fields = { ...record }; // Ensure record has Id and necessary fields
                return updateRecord({ fields });
            });
        
            try {
                await Promise.all(updatePromises);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Drawing Number LI data updated successfully',
                    variant: 'success'
                }));
                this.draftValues = [];
                await refreshApex(this.wiredDNLiResult);
            } catch (error) {
                console.error('Error updating DN_LI records:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to update DN_LI records',
                    variant: 'error'
                }));
            }
        }
        
        async handleDimensionsSave(event) {
            const updatedFields = event.detail.draftValues;
            const updatePromises = updatedFields.map(record => {
                const fields = { ...record }; // Ensure record has Id and necessary fields
                return updateRecord({ fields });
            });
        
            try {
                await Promise.all(updatePromises);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Dimensions data updated successfully',
                    variant: 'success'
                }));
                this.draftValues = [];
                await refreshApex(this.wiredDimensionDataResult);
            } catch (error) {
                console.error('Error updating dimension records:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to update dimension records',
                    variant: 'error'
                }));
            }
        }

        handleDimensionRowAction(event)
        {

        }

    

}
