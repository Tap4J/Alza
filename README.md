# Alza
Alza case study

## Guidelines
**Install Libraries from Requirements Using pip**
1. Open your terminal (macOS/Linux) or command prompt (Windows).
2. Navigate to the directory where you have downloaded/cloned the repository.
    ```sh
    cd path/to/your/project
    ```
3. (Optional) Create and activate a virtual environment:
      ```sh
      python3 -m venv env
      source venv/bin/activate
      ```
5. Install the required libraries using `pip`:

    ```sh
    pip install -r requirements.txt
    ```
**Run Jupyter Lab with the Notebook and Data**

To run the Jupyter Notebook with all the data in the GitHub repository, follow these steps:

1. Ensure you are still in the project directory.
2. Start Jupyter Lab:

    ```sh
    jupyter lab
    ```
3. A new tab will open in your default web browser, displaying the Jupyter Lab interface.
4. In Jupyter Lab, navigate to the directory where the notebook file (`.ipynb`) is located.
5. Open the notebook file to begin working with it.

## Assignment Task
**Úkoly:**
1. DB obsahuje mimo obecných obchodních dat i informace o zákaznících, kteří jsou členy
benefitního programu. Analyzuj tuto skupinu.
    - Zajímá nás především, jak se změnilo nákupní chování a hodnota zákazníků kteří do
programu vstoupili,
    - a porovnání se zbytkem zákazníků

2. Projdi si DB a najdi zajímavé insighty (stačí 3), které bys mohl/a nabídnout
businessu/managementu.

Translation: \
\
**Tasks:**
1. DB contain info about customers who are part of benefit program. Analyse this group.
     - How does customer behaviour change after they enter the program
     - Compare with rest of customers
   
2. Go through DB and find interesting insight (max 3) for business/management

## Key results

1. **Customers not in the program spend more on average and also make more purchases. They are also the largest group of customers with the highest total amount spent.**
2. **After joining the program customers tend to spend more and to do more purchases. In the visualisation is clear that customers make more purchases and that their behaviour positively changes toward higher spending.**
3. **Customers in the program are smaller customer segments but the total amount spent and number of purchases are still impressive as there are approximately 73 times more companies not enlisted in the program than are. Thus benefit programs should be supported additionally to increase customer base.**
