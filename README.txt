: READ.ME :

The techinque used here is :
1. Get the template of the running stack into a dump.json file
2. Pick changes from change.properties
3. Run update_stack with  --template-body file:///dump.json along with changed parameters from the change.properties file

Example change.properties
ParameterKey=environmentType,UsePreviousValue=true ParameterKey=DBPassword,UsePreviousValue=true 

How to run the script (while your stackname is MyStack):
./reparse_value.sh MyStack
