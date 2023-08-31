# OrderMatchingAnalytics
Package Name: OrderMatchingAnalytics

Description:
This package contains code that combines the use of SAS and Matlab for the purpose of data cleaning, filtering, tracing, and order matching analysis. The primary objectives are to match sell and buy orders executed by a dealer, calculate the resulting spread as the numerical difference between the sell and buy prices, and explore how the dealer applies varying spreads or price adjustments based on specific factors. These factors include the nature of the counterparty (dealer or client), as well as whether there is a history of frequent trading interactions with the counterparty.

Key Features:

Data Cleaning and Filtering: Utilizing SAS, this code provides functions for data cleaning and filtering to ensure the dataset's integrity and quality.

Order Matching with Spread Calculation: The Matlab component of the code focuses on matching sell and buy orders. The calculated spread is derived by subtracting the buy price from the sell price.

Analyzing Spread Differential: The code aims to decipher how the dealer enforces diverse spreads or price differentials. This differentiation is based on specific attributes such as the type of counterparty involved—be it another dealer, a client—or the historical frequency of trades with the given counterparty.

Matching Algorithm:

The initial step involves matching orders that were executed within the same day.

Subsequently, the algorithm widens its scope by considering buy orders from the past 60 days. These cumulative buy orders are juxtaposed against a single sell order.

For complex scenarios that span multiple days, the matching algorithm seamlessly shifts to Matlab for intricate processing.

Attribution and Code Adaptation:
Certain segments of this codebase are directly inspired by existing literature. To acknowledge these sources appropriately, comprehensive citations have been incorporated directly within the code comments.

Usage:

Utilize the SAS functions for data cleaning, filtering, and tracing to prepare the dataset for analysis.

Leverage the Matlab code to conduct order matching and calculate spreads between sell and buy orders.

Interpret the results to discern how the dealer's spread imposition varies based on different counterparty attributes.

Note:
This package is designed to provide insights and tools for order matching analysis. Proper understanding of SAS and Matlab environments is recommended for effective utilization.

Disclaimer:
This package comes with no warranties. Users are advised to review and adapt the code as necessary for their specific requirements.

We welcome contributions and feedback to enhance and expand this package.
