import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// Set busstop object fields
const NAME_FIELD = 'Busstop__c.Name';
const DESCRIPTION_FIELD = 'Busstop__c.Description__c';
const LOCATION_LATITUDE_FIELD = 'Busstop__c.Geolocation__Latitude__s';
const LOCATION_LONGITUDE_FIELD = 'Busstop__c.Geolocation__Longitude__s';
const busstopFields = [
	NAME_FIELD,
	LOCATION_LATITUDE_FIELD,
	LOCATION_LONGITUDE_FIELD,
  DESCRIPTION_FIELD
];


export default class BusstopLocation extends LightningElement {

  mapOptions = {
    disableDefaultUI: true, // when true disables Map|Satellite, +|- zoom buttons
    zoomControl: true,
    };

  zoomLevel = "15";
  mapMarkers = [];
  
  @api
  recordId;

  @api
  name;


  @wire(getRecord, { recordId: '$recordId', fields: busstopFields })
  loadBusstop({ error, data }) {
    if (error) {
      // TODO: handle error
    } else if (data) {
      // Get busstop data
      this.name = getFieldValue(data, NAME_FIELD);
      this.description = getFieldValue(data, DESCRIPTION_FIELD);
      const Latitude = getFieldValue(data, LOCATION_LATITUDE_FIELD);
      const Longitude = getFieldValue(data, LOCATION_LONGITUDE_FIELD);
      // Transform busstop data into map markers
      this.mapMarkers = [{
        location: { Latitude, Longitude },
        title: this.name,
        description: this.description
      }];
    }
  }
  get cardTitle() {
    return (this.name) ? `${this.name}` : 'Busstop location';
  }
}