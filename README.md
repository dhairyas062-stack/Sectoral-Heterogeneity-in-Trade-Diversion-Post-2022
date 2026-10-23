Project Title: Geopolitical Beta: Sectoral Heterogeneity in Trade Diversion Post-2022Author: Dhairya Shah, dhairya.shah_ug2024@ashoka.edu.in
📄 OverviewThis repository contains the replication datasets and Stata code for my ongoing working paper.
Research Question: How does the dyadic geopolitical alignment of trading partners influence trade diversion following the 2022 Russia-Ukraine shock, and does this effect vary across technology intensity sectors?
Abstract: This project investigates the empirical presence of "friend-shoring" following the 2022 Russia-Ukraine shock. Using bilateral trade data from CEPII BACI, Lall (2000) technology sectors, and UN General Assembly ideal points, I estimate a structural gravity model via PPML with high-dimensional fixed effects. Post-2022, highly aligned exporters aggressively reduced high-technology exports to non-aligned importers ($\beta$ = -0.568, p = 0.006). Estimates for medium- and low-technology goods are not statistically significant. The results suggest geopolitical trade realignment is heavily concentrated in security-sensitive high-technology sectors rather than being an economy-wide macroeconomic fragmentation.

📝 Working Paper Summary

Introduction
The 2022 Russia-Ukraine conflict catalyzed a reevaluation of global supply chain vulnerabilities, prompting a surge in industrial policies and rhetoric aimed at "friend-shoring" and geoeconomic fragmentation. Understanding the true extent of this fragmentation is critical, as a complete bifurcation of global trade threatens macroeconomic stability and global growth. However, policy rhetoric often outpaces empirical reality. This project attempts to answer whether trade is genuinely being rerouted based on geopolitical alliances, and crucially, whether this phenomenon is uniform across all types of manufactured goods.My primary contribution is shifting the analytical focus from aggregate macroeconomic decoupling to granular, dyadic sectoral heterogeneity. Previous literature frequently assesses total trade volumes or employs crude bloc-level dummies. In contrast, this study utilizes a continuous measure of geopolitical distance and introduces the Lall (2000) technology classification to isolate the exact supply chains reacting to political friction.

Data & Empirical Strategy
The study uses bilateral trade flow data from the CEPII BACI database (HS1996 nomenclature), combined with UNGA Voting Ideal Points to calculate continuous dyadic alignment scores. The data spans a 6-year timeline from 2019 to 2024, capturing a balanced pre- and post-shock window, resulting in a dataset of roughly 277,000 dyad-year-sector observations. The empirical framework relies on a Poisson Pseudo-Maximum Likelihood (PPML) structural gravity model. By employing high-dimensional fixed effects (dyadic, exporter-time, and importer-time), the model strictly controls for multilateral resistance and unobserved country-level shocks, isolating the triple-interaction term (Exporter US Alignment $\times$ Importer Non-Alignment $\times$ Post-2022).

Main Findings
High-Technology Sector (N = 84,234): We estimate a statistically significant, negative geopolitical beta of -0.568 ($p = 0.006$). Post-shock, highly aligned countries restricted their advanced technology exports to non-aligned markets, pointing toward stringent friend-shoring and active export controls.Medium-Technology Sector (N = 99,222): The coefficient is -0.185 but statistically insignificant ($p = 0.210$). Capital-intensive supply chains (e.g., automotive, basic machinery) were not systematically diverted by political misalignment.Low-Technology Sector (N = 94,298): The coefficient is -0.270 and statistically insignificant ($p = 0.186$). Highly elastic consumer goods trade shows no systemic responsiveness to dyadic geopolitical shocks.

Conclusion & Limitations
The empirical evidence decisively rejects the hypothesis of a sweeping, aggregate fragmentation of global trade along geopolitical lines. Instead, the negative and significant coefficient exclusive to the high-technology sector points to a highly targeted intervention framework. Friend-shoring manifests primarily through strict export controls on advanced, potentially dual-use goods aimed at preventing technology leakage. Meanwhile, traditional manufacturing, capital goods, and low-tech consumer supply chains remain fundamentally resilient and agnostic to political alignment shocks.
Several limitations warrant consideration. First, reliance on UNGA voting records captures formal diplomatic posture but may obscure deeper, informal geoeconomic ties. Second, applying the static Lall (2000) framework to contemporary trade may fail to adequately capture emerging digital services or the increasingly blurred lines of modern dual-use technologies. Finally, physical supply chains possess immense inertia; the brief 2022-2024 post-shock window primarily captures immediate policy shocks (like bans or export controls) rather than the long-term, structural relocation of global capital. Future research should extend the temporal scope, integrate firm-level customs data to expose heterogeneous corporate responses, and explicitly map third-country routing through non-aligned "connector" economies acting as transit hubs.

📊 Data Availability & Origin
•	data/BACI_HS96_Y*_V202601.csv: Sourced from CEPII BACI Database. (Note: Due to massive file sizes, the raw CSVs are not uploaded to this repository. Please download them directly from CEPII and place them in the /data folder).
•	data/IdealpointsJuly2025.dta: Sourced from the UNGA Voting Ideal Points database (Bailey, Strezhnev, & Voeten).
•	data/HS1996 to SITC3 Conversion and Correlation Tables.xls: Sourced from the UN UNSD correspondence tables.
•	data/collapsed_trade_sectoral.dta: The finalized, lightweight analytical panel dataset generated by the master script.

💻 Stata Replication Instructions
Requirements
•	Stata Version: Stata 16 or higher is recommended.
•	Required Packages: This code requires the following user-written packages. Due to indexing issues with SSC, the master script installs the structural gravity packages directly from GitHub.
o	ssc install kountry, replace
o	ssc install estout, replace

Execution Steps
1)	Clone or download this repository to your local machine. Ensure your folder structure has a /data folder containing the raw files.
2)	Open Stata and change your working directory (cd) to the root folder of this project.
3)	Open and run stata_code/01_master.do.Note: The master script utilizes dynamic pathing (global project_root "\c(pwd)'"`) to automatically route directories without requiring manual path edits.
4)	The script cleans the data, executes the PPML models, and outputs all results into a newly created /results folder.
📈 Key Outputs Generated
•	results/sectoral_diversion.tex: The primary LaTeX regression table reporting the PPML estimates and standard errors across the High, Medium, and Low-Tech sectors.
📚 Citations
•	Alfaro, L., & Chor, D. (2023). Global Supply Chains: The Looming "Great Reallocation". NBER Working Paper No. 31661.
•	Bailey, M. A., Strezhnev, A., & Voeten, E. (2017). Estimating Dynamic State Preferences from United Nations Voting Data. Journal of Conflict Resolution, 61(2), 430-456.
•	CEPII. (n.d.). BACI: International Trade Database at the Product-Level.
•	Gopinath, G., Gourinchas, P. O., Presbitero, A. F., & Topalova, P. (2024). Geoeconomic Fragmentation and the Future of Macroeconomic Policy. International Monetary Fund.
•	Lall, S. (2000). The Technological Structure and Performance of Developing Country Manufactured Exports, 1985‐98. Oxford Development Studies, 28(3), 337-369.
•	Silva, J. M. C. S., & Tenreyro, S. (2006). The Log of Gravity. The Review of Economics and Statistics, 88(4), 641-658.

✉️ Feedback & Contact
This is a work in progress. If you spot any bugs in the .do files or have suggestions regarding the empirical strategy, please open an Issue on this repository or contact me directly at dhairya.shah_ug2024@ashoka.edu.in.
