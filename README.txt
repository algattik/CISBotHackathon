

Requirements:
- Windows system with Internet connection without troublesome proxy
- Visual Studio
- Azure PowerShell

How to build and run:
- In Windows PowerShell ISE, run the scripts in the Scripts directory.
  Watch for any errors.

*** TODO ***

- Add event correlation to Stream Analytics job to output dataset to Power BI
  allowing to show the offer acceptance rate over time. It should show it
  increasing from 50% to over 60% after enabling the Azure ML model
- Improve very slow "conversation simulator". I tried parallelizing execution
  but that resulted in Server errors (throttling?)
- In ML, filter out noise (None intent)
- Order ML training set by time
- In PowerPoint, advise users to look at the ADL JSON files and the training
  CSV file before starting with ML
- In PowerPoint, add slides with background info about each product (e.g. Event
  Hubs)
- In PowerPoint, explain choice of regression model
- Automate Azure Function creation
- Automate Logic App creation
