import { LightningElement, api, wire, track } from 'lwc';
import getSchools from '@salesforce/apex/ImportsRunnerController.getSchools';
import getSchoolYears from '@salesforce/apex/ImportsRunnerController.getSchoolYears';
import startBatch from '@salesforce/apex/ImportsRunnerController.startBatch';
import getJobStatus from '@salesforce/apex/ImportsRunnerController.getJobStatus';
import getSummary from '@salesforce/apex/ImportsRunnerController.getSummary';
export default class ImportsRunner extends LightningElement {

	@api
	recordId;
	error;

	nextLabel = 'Start processing';
	activeStep = 'step-1';

	schools;
	schoolyears;

	selectedSchool;
	selectedSchoolLabel;
	selectedSchoolyear;
	selectedSchoolyearLabel;

	summary;
	currentJobId;
	currentJobStatus = {status:'Initializing'};

	classesJobId;
	parentsJobId;
	studentsJobId;
	// classesJobId = '7077Z00004Au06n';
	// parentsJobId = '7077Z00004Au0C5';
	// studentsJobId = '7077Z00004Au0mh';

	@track
	hideNextButton = false;
	@track
	hidePreviousButton = false;

	@wire(getSchools)
	wiredSchools(result) {
		const { error, data } = result;
 
		if (error) {
				console.error(JSON.stringify(error));
		} else if (data) {
				this.schools = data;
		}
	};

	@wire(getSchoolYears)
	wiredYears(result) {
		const { error, data } = result;

		if (error) {
				console.error(JSON.stringify(error));
		} else if (data) {
				this.schoolyears = data;
		}
	};

	renderedCallback(){
			// this.getSummaryData();
	}

	getSummaryData()
	{
		getSummary({classesJobId: this.classesJobId, parentsJobId: this.parentsJobId, studentsJobId: this.studentsJobId})
				.then( (result) => {
					this.summary = result;
				})
				.catch((error) => {
					console.error(JSON.stringify(error));
				});
	}

	// .then( (result) => {
	// 	this.currentJobStatus = result;
	// 	if (this.currentJobStatus.status == 'Completed')
	// 	{
	// 		clearInterval(this._interval);
	// 		this.advanceStep();
	// 	}
	// })
	// .catch((error) => {
	// 	console.error(JSON.stringify(error));
	// });

	validate () {
		// 1 - Takes all the inputs from the step - "this" is bind to wizard-step component
		const allValid = [...this.querySelectorAll('lightning-combobox')]
		.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
		}, true);

		// 2 - Returns true/false; if the validation were asynchronous, it should return a Promise instead
		return allValid;
	}

	get classesJob()
	{
		return this.summary.find(job => job.id == this.classesJobId);
	}

	get parentsJob()
	{
		return this.summary.find(job => job.id == this.parentsJobId);
	}

	get studentsJob()
	{
		return this.summary.find(job => job.id == this.studentsJobId);
	}

	get jobProgressVariant() {
		let variant = "base";
		if (this.currentJobStatus?.numberOfErrors)
		{
			variant = "warning";
		}
		else if (this.currentJobStatus?.status == "Failed")
		{
			variant = "expired";
		}
		else if (this.currentJobStatus?.status == "Completed")
		{
			variant = "base-autocomplete";
		}
		return variant;
	}

	get jobProgress() {
		const statusInfo = this.currentJobStatus;
		if (statusInfo?.steps) {
			return (statusInfo?.currentStep / statusInfo?.steps) * 100;
		}
		else {
			return 0;
		}
	}

	handleSchoolChange(event){
		this.selectedSchool = event.detail.value;
		this.selectedSchoolLabel = this.schools.find(school => school.value === event.detail.value).label;
	}

	handleSchoolyearChange(event){
		this.selectedSchoolyear = event.detail.value;
		this.selectedSchoolyearLabel = this.schoolyears.find(year => year.value === event.detail.value).label;
	}

	handleStepChange(event){
		// oldStep: self._currentStep,
		// currentStep: stepName
		const oldStep = event.detail.oldStep;
		const newStep = event.detail.currentStep;

		if (oldStep == 'step-1' && newStep == 'step-2') {
			this.activeStep = 'step-2';
			this.hideNextButton = true;
			this.hidePreviousButton = true;
			this.startBatchJob('CLASSES');
			this.nextLabel = 'Next';
		}
	}

	updateJobStatus() {
		getJobStatus({jobId : this.currentJobId})
				.then( (result) => {
					this.currentJobStatus = result;
					if (this.currentJobStatus.status == 'Completed')
					{
						clearInterval(this._interval);
						this.advanceStep();
					}
				})
				.catch((error) => {
					console.error(JSON.stringify(error));
				});
	}

	startBatchForCurrentStep()
	{
		if (this.activeStep == 'step-3') { 
			this.startBatchJob('PARENTS');
		} else if (this.activeStep == 'step-4') {
			this.startBatchJob('STUDENTS');
		} else if (this.activeStep == 'step-5') {
			this.getSummaryData();
			this.hidePreviousButton = true;
			// Gather status information
		};
	}

	advanceStep() {
		if (this.currentJobStatus?.status == 'Completed' && this.currentJobStatus?.numberOfErrors == 0)
		{
			let currentStep = this.activeStep;
			let stepNumber = currentStep.charAt(currentStep.length-1);
			this.activeStep = currentStep.substring(0, 5) + ((stepNumber * 1) + 1);
			console.log('Advancing to next step: ' + this.activeStep);
			this.currentJobStatus = null;
			this.startBatchForCurrentStep();
		} else {
			console.log('Some error happened, not auto-advancing to next job');
			this.hideNextButton = false;
			this.hidePreviousButton = false;
			this.error = this.currentJobStatus.statusMessage;
		}
	}

	startBatchJob(jobType)
	{
		startBatch({jobType : jobType, schoolId : this.selectedSchool, yearId : this.selectedSchoolyear})
			.then( (result) => {
				this.currentJobId = result;

				switch(jobType) {
					case 'PARENTS':
						this.parentsJobId = result;
						break;
					case 'STUDENTS':
						this.studentsJobId = result;
						break;
					case 'CLASSES':
						this.classesJobId = result;
						break;
				}

				this.updateJobStatus();
				this._interval = setInterval(this.updateJobStatus.bind(this), 1000); //repeat every second
			})
			.catch((error) => {
				console.error(JSON.stringify(error));
			});
	}

}