import { LightningElement , api, wire } from "lwc";
import getMarkersForRoute from "@salesforce/apex/BusrouteMapController.getMarkersForRoute";

export default class BusrouteMap extends LightningElement {
	@api
	recordId;

	@api
	objectApiName;

	@api
	_cardTitle;

	@api
	_listTitle;

	error;
	markers;



	mapOptions = {
    disableDefaultUI: true, // when true disables Map|Satellite, +|- zoom buttons
    zoomControl: true,
	};

	@wire(getMarkersForRoute, {routeId: '$recordId'})
		wiredMarkers({ error, data }) {
        if (data) {
            this.error = undefined;
            this.markers = data;
        } else if (error) {
            this.error = error;
            this.markers = [];
        }
	}

	get cardTitle() {
		return (this._cardTitle) ? this._cardTitle : 'Map';
	}

	get listTitle() {
		return (this._listTitle) ? this._listTitle : 'Busstops';
	}
}