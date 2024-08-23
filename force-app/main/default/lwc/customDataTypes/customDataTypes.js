import { LightningElement } from 'lwc';
import LightningDataTable from 'lightning/datatable';
import customAssembly from './customAssembly.html';
import customCutView from './customCutView.html';
import customDrawing from './customDrawing.html';

export default class CustomDataTypes extends LightningDataTable {
    static customTypes = {
        customAssembly: {
            template: customAssembly,
            standardCellOutput: true,
            typeAttributes: ['AssemblyDrawing']
        },

        customCutView: {
            template: customCutView,
            standardCellOutput: true,
            typeAttributes: ['CutViewDrawing']
        },
        
        customDrawing: {
            template: customDrawing,
            standardCellOutput: true,
            typeAttributes: ['drawingImage']
        }
    }
}
