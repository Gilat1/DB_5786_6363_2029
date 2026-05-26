import random
from faker import Faker

fake = Faker()

START_ID = 20101
END_ID = 20500

def generate_payment_inserts():
    """
    Generates INSERT statements for PAYMENT table
    from PaymentID 20101 to 20500.
    """

    print(f"Generating inserts from {START_ID} to {END_ID}...")

    payment_methods = [
        'Credit Card',
        'Bank Transfer',
        'PayPal',
        'Cash',
        'Check'
    ]
    
    MAX_REGISTRATION_ID = 20000
    MAX_STATUS_ID = 5

    with open(
        'phase1/Programing/insert_payments.sql',
        mode='w',
        encoding='utf-8'
    ) as file:

        file.write("-- PAYMENT INSERTS\n\n")

        for pay_id in range(START_ID, END_ID + 1):

            pay_date = fake.date_between(
                start_date='-2y',
                end_date='today'
            ).strftime('%Y-%m-%d')

            amount = round(
                random.uniform(10.0, 9999.99),
                2
            )

            notes = fake.sentence(nb_words=10)
            notes = notes.replace("'", "''").replace("\n", " ")

            if len(notes) > 500:
                notes = notes[:497] + "..."

            method = random.choice(payment_methods)

            ref_num = fake.bothify(
                text='REF-#######-??'
            ).upper()

            reg_id = random.randint(
                1,
                MAX_REGISTRATION_ID
            )

            status_id = random.randint(
                1,
                MAX_STATUS_ID
            )

            sql = (
                f"INSERT INTO PAYMENT "
                f"(PaymentID, PaymentDate, Amount, Notes, "
                f"PaymentMethod, ReferenceNumber, RegistrationID, PaymentStatusID) "
                f"VALUES "
                f"({pay_id}, "
                f"TO_DATE('{pay_date}', 'YYYY-MM-DD'), "
                f"{amount}, "
                f"'{notes}', "
                f"'{method}', "
                f"'{ref_num}', "
                f"{reg_id}, "
                f"{status_id});\n"
            )

            file.write(sql)

    print("Success! 'insert_payments.sql' has been created.")


if __name__ == '__main__':
    generate_payment_inserts()