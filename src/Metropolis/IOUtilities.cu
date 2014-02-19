//This file/class will, ideally, replace Config_Scan.cpp. -Albert


/*!\file
  \brief Class used to read and write configuration files.
  \author Alexander Luchs, Riley Spahn, Seth Wooten, and Orlando Acevedo
 
 */
 
 

#include "IOUtilities.h"
#include "errno.h"

IOUtilities::IOUtilities(string configPath){
    configpath = configPath;
    memset(&enviro,0,sizeof(Environment)); //the Environment is a struct, so this is apparently the best way to instantiate the struct
    numOfSteps=0;
}

void IOUtilities::readInConfig()
{
    ifstream configscanner(configpath.c_str());
    if (! configscanner.is_open())
    {
        throwScanError("Configuration file failed to open.");
        return;
    }
    else
    {
        string line;
        int currentLine = 1;
        while (configscanner.good())
        {
            getline(configscanner,line);
			
            //assigns attributes based on line number
            switch(currentLine)
            {
                case 2:
					if(line.length() > 0)
					{
						enviro.x = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment x value.");
						return;
					}
                    break;
                case 3:
					if(line.length() > 0)
					{
						enviro.y = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment y value.");
						return;
					}
                    break;
                case 4:
					if(line.length() > 0)
					{
						enviro.z = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment z value.");
						return;
					}
                    break;
                case 6:
					if(line.length() > 0)
					{
						enviro.temperature = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment temperature value.");
						return;
					}
                    break;
                case 8:
					if(line.length() > 0)
					{
						enviro.maxTranslation = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment max translation value.");
						return;
					}
                    break;
                case 10:
					if(line.length() > 0)
					{
						numOfSteps = atoi(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing number of steps value.");
						return;
					}
                    break;
                case 12:
					if(line.length() > 0)
					{
						enviro.numOfMolecules = atoi(line.c_str());
						//printf("number is %d",enviro.numOfMolecules);
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing number of molecules value.");
						return;
					}
                    break;
                case 14:
					if(line.length() > 0)
					{
						oplsuaparPath = line;
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing oplsuapar path value.");
						return;
					}
                    break;
                case 16:
					if(line.length() > 0)
					{
						zmatrixPath = line;
					}
					else
					{
						throwScanError("Configuration file not well formed. Missing z-matrix path value.");
						return;
					}
                    break;
                case 18:
                    if(line.length() > 0)
					{
                        statePath = line;
                    }
                    break;
                case 20:
                    if(line.length() > 0){
                        stateOutputPath = line;
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing state file output path value.");
						return;
					}
                    break;
                case 22:
                    if(line.length() > 0){
                        pdbOutputPath = line;
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing PDB output path value.");
						return;
					}
                    break;
                case 24:
					if(line.length() > 0)
					{
						enviro.cutoff = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment cutoff value.");
						return;
					}
                    break;
                case 26:
					if(line.length() > 0)
					{
						enviro.maxRotation = atof(line.c_str());
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment max rotation value.");
						return;
					}
                    break;
                case 28:
                    if(line.length() > 0){
						enviro.randomseed=atoi(line.c_str());
                    }
                	break;
                case 30:
                    if(line.length() > 0){
						// Convert to a zero-based index
						enviro.primaryAtomIndex=atoi(line.c_str()) - 1;
                    }
					else
					{
						throwScanError("Configuration file not well formed. Missing environment primary atom index value.");
						return;
					}
                	break;
            }
			
			currentLine++;
        }
    }
}

void IOUtilities::throwScanError(string message)
{

	cerr << endl << message << endl << "	Error Number: " << errno << endl <<endl;

	return;
}


/**
	This method is used to read in from a state file.
	
	@param StateFile - takes the location of the state file to be read in
*/
int IOUtilities::ReadStateFile(char const* StateFile)
{
    ifstream inFile;
    Environment tmpenv;
    stringstream ss;
    char buf[250];
    
    cout<<"read state file "<<StateFile<<endl;
    //save current Enviroment to tmpenv at first
    memcpy(&tmpenv,enviro,sizeof(Environment));
    
    inFile.open(StateFile);
    
    //read and check the environment
    if (inFile.is_open())
    {
      inFile>>tmpenv.x>>tmpenv.y>>tmpenv.z>>tmpenv.maxTranslation>>tmpenv.numOfAtoms>>tmpenv.temperature>>tmpenv.cutoff;
    }
    
    if (memcmp(&tmpenv,enviro,sizeof(Environment))!=0)
    {
       ss<<"Wrong state files,does not match other configfiles"<<endl;
       ss<<"x "<<tmpenv.x<<" "<<enviro->x<<endl;
       ss<<"y "<<tmpenv.y<<" "<<enviro->y<<endl;
       ss<<"z "<<tmpenv.z<<" "<<enviro->z<<endl;
       ss<<"numOfAtoms "<<tmpenv.numOfAtoms<<" "<<enviro->numOfAtoms<<endl;
       ss<<"temperature "<<tmpenv.temperature<<" "<<enviro->temperature<<endl;
       ss<<"cutoff "<<tmpenv.cutoff<<" "<<enviro->cutoff<<endl;
       ss<<ss.str()<<endl; writeToLog(ss);      
    } 
    inFile.getline(buf,sizeof(buf)); //ignore blank line
    int molecno,atomno;

    molecno=0;
    atomno=0;
    
    int no;
    Atom currentAtom;
   	Bond  currentBond;
 	Angle currentAngle;
    Dihedral currentDi;
 	Hop      currentHop;
 	Molecule *ptr=molecules;;

    while(inFile.good()&&molecno<enviro->numOfMolecules)
    {
        inFile>>no;
        assert(ptr->id==no);
        inFile.getline(buf,sizeof(buf)); //bypass atom flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"= Atoms")==0);

        for(int i=0;i<ptr->numOfAtoms;i++)
        {
        	inFile>>currentAtom.id >> currentAtom.x >> currentAtom.y >> currentAtom.z>> currentAtom.sigma >> currentAtom.epsilon >> currentAtom.charge;
        	assert(currentAtom.id==ptr->atoms[i].id);
        	//printf("id:%d,x:%f,y:%f\n",currentAtom.id,currentAtom.x,currentAtom.y);
        	memcpy(&ptr->atoms[i],&currentAtom,sizeof(Atom));
        }

        inFile.getline(buf,sizeof(buf)); //ignore bonds flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"= Bonds")==0);
        for(int i=0;i<ptr->numOfBonds;i++)
        {
        	inFile>>currentBond.atom1 >>currentBond.atom2 >> currentBond.distance >> currentBond.variable;
        	assert(currentBond.atom1==ptr->bonds[i].atom1);
        	assert(currentBond.atom2==ptr->bonds[i].atom2);      	
        	memcpy(&ptr->bonds[i],&currentBond,sizeof(Bond));
        }

        inFile.getline(buf,sizeof(buf)); //ignore Dihedrals flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"= Dihedrals")==0);
        for(int i=0;i<ptr->numOfDihedrals;i++)
        {
        	inFile>>currentDi.atom1>>currentDi.atom2>>currentDi.value>>currentDi.variable;
        	assert(currentDi.atom1==ptr->dihedrals[i].atom1);
        	assert(currentDi.atom2==ptr->dihedrals[i].atom2);      	
        	memcpy(&ptr->dihedrals[i],&currentDi,sizeof(Dihedral));
        }

        inFile.getline(buf,sizeof(buf)); //ignore hops flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"=Hops")==0);
        // known BUG - if molecule has no hops (3 atoms or less) state file gives error crashing simulation
        for(int i=0;i<ptr->numOfHops;i++)
        {
        	inFile>>currentHop.atom1>>currentHop.atom2 >>currentHop.hop;
        	assert(currentHop.atom1==ptr->hops[i].atom1);
        	assert(currentHop.atom2==ptr->hops[i].atom2);      	
        	memcpy(&ptr->hops[i],&currentHop,sizeof(Hop));
        }

        inFile.getline(buf,sizeof(buf)); //ignore angles flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"= Angles")==0);
        for(int i=0;i<ptr->numOfAngles;i++)
        {
        	inFile>>currentAngle.atom1 >> currentAngle.atom2 >>currentAngle.value >>currentAngle.variable;
        	assert(currentAngle.atom1==ptr->angles[i].atom1);
        	assert(currentAngle.atom2==ptr->angles[i].atom2);      	
        	memcpy(&ptr->angles[i],&currentAngle,sizeof(Angle));
        }       

        inFile.getline(buf,sizeof(buf)); //bypass == flag
        inFile.getline(buf,sizeof(buf));
        assert(strcmp(buf,"==")==0);   

        ptr++;                    
        molecno++;
    }
    inFile.close();
    WriteStateFile("Confirm.state");

	return 0;
}

/**
	Used to write to a state file.
	@param StateFile - writes to a state file at the location given
*/
int IOUtilities::WriteStateFile(char const* StateFile)
{
    ofstream outFile;
    int numOfMolecules=enviro->numOfMolecules;
    
    outFile.open(StateFile);
    
    //print the environment
    outFile << enviro->x << " " << enviro->y << " " << enviro->z << " " << enviro->maxTranslation<<" " << enviro->numOfAtoms
        << " " << enviro->temperature << " " << enviro->cutoff <<endl;
    outFile << endl; // blank line
    
    for(int i = 0; i < numOfMolecules; i++)
    {
        Molecule currentMol = molecules[i];
        outFile << currentMol.id << endl;
        outFile << "= Atoms" << endl; // delimiter
    
        //write atoms
        for(int j = 0; j < currentMol.numOfAtoms; j++)
        {
            Atom currentAtom = currentMol.atoms[j];
            outFile << currentAtom.id << " "
                << currentAtom.x << " " << currentAtom.y << " " << currentAtom.z
                << " " << currentAtom.sigma << " " << currentAtom.epsilon  << " "
                << currentAtom.charge << endl;
        }
        outFile << "= Bonds" << endl; // delimiter
        
        //write bonds
        for(int j = 0; j < currentMol.numOfBonds; j++)
        {
            Bond currentBond = currentMol.bonds[j];
            outFile << currentBond.atom1 << " " << currentBond.atom2 << " "
                << currentBond.distance << " ";
            if(currentBond.variable)
                outFile << "1" << endl;
            else
                outFile << "0" << endl;

        }
        outFile << "= Dihedrals" << endl; // delimiter
        for(int j = 0; j < currentMol.numOfDihedrals; j++)
        {
            Dihedral currentDi = currentMol.dihedrals[j];
            outFile << currentDi.atom1 << " " << currentDi.atom2 << " "
                << currentDi.value << " ";
            if(currentDi.variable)
            {
                outFile << "1" << endl;
            }
            else
            {
                outFile << "0" << endl;
            }
        }

        outFile << "=Hops" << endl;

        for(int j = 0; j < currentMol.numOfHops; j++)
        {
            Hop currentHop = currentMol.hops[j];

            outFile << currentHop.atom1 << " " << currentHop.atom2 << " "
                << currentHop.hop << endl;
        }
        
        
        outFile << "= Angles" << endl; // delimiter

        //print angless
        for(int j = 0; j < currentMol.numOfAngles; j++)
        {
            Angle currentAngle = currentMol.angles[j];

            outFile << currentAngle.atom1 << " " << currentAngle.atom2 << " "
                << currentAngle.value << " ";
            if(currentAngle.variable)
            {
                outFile << "1" << endl;
            }
            else
            {
                outFile << "0" << endl;
            }
        }


        //write a == line
        outFile << "==" << endl;
    }
    outFile.close();
	return 0;
}

/**
	writes to a PDB file for visualizing the box
	@param pdbFile - Location of the pdbFile to be written to
*/
int SimBox::writePDB(char const* pdbFile)
{
    ofstream outputFile;
    outputFile.open(pdbFile);
    int numOfMolecules=enviro->numOfMolecules;
    outputFile << "REMARK Created by MCGPU" << endl;
    //int atomIndex = 0;
    for (int i = 0; i < numOfMolecules; i++)
    {
    	Molecule currentMol = molecules[i];    	
        for (int j = 0; j < currentMol.numOfAtoms; j++)
        {
        	Atom currentAtom = currentMol.atoms[j];
            outputFile.setf(ios_base::left,ios_base::adjustfield);
            outputFile.width(6);
            outputFile << "ATOM";
            outputFile.setf(ios_base::right,ios_base::adjustfield);
            outputFile.width(5);
            outputFile << currentAtom.id + 1;
            outputFile.width(3); // change from 5
            outputFile << currentAtom.name;
            outputFile.width(6); // change from 4
            outputFile << "UNK";
            outputFile.width(6);
            outputFile << i + 1;
            outputFile.setf(ios_base::fixed, ios_base::floatfield);
            outputFile.precision(3);
            outputFile.width(12);
            outputFile << currentAtom.x;
            outputFile.width(8);
            outputFile << currentAtom.y;
            outputFile.width(8);
            outputFile << currentAtom.z << endl;
        }
        outputFile << "TER" << endl;
    }
    outputFile << "END" << endl;
    outputFile.close();

	return 0;
}