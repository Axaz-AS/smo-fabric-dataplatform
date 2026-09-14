[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Ansatt-Navn_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Ansatt-Navn" = let
  Source = SharePoint.Files("https://sophiesmindeortopedi.sharepoint.com", [ApiVersion = 15]),
  Navigation = Source{[Name = "mapping_ansattnavn_nobs.xlsx", #"Folder Path" = "https://sophiesmindeortopedi.sharepoint.com/Shared Documents/PowerBI SMO/"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Navigation 1" = #"Imported Excel workbook"{[Item = "Ark1", Kind = "Sheet"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 1", {{"Column1", type text}, {"Column2", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true])
in
  #"Promoted headers";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Tidskategori_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Tidskategori = let
  Source = SharePoint.Files("https://sophiesmindeortopedi.sharepoint.com", [ApiVersion = 15]),
  Navigation = Source{[Name = "mapping_tidskategori_capitech.xlsx", #"Folder Path" = "https://sophiesmindeortopedi.sharepoint.com/Shared Documents/PowerBI SMO/"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Navigation 1" = #"Imported Excel workbook"{[Item = "Tidskategori", Kind = "Sheet"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 1", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true])
in
  #"Promoted headers";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Nomenklatur_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Nomenklatur = let
  Source = SharePoint.Files("https://sophiesmindeortopedi.sharepoint.com", [ApiVersion = 15]),
  Navigation = Source{[Name = "mapping_nomenklatur.xlsx", #"Folder Path" = "https://sophiesmindeortopedi.sharepoint.com/Shared Documents/PowerBI SMO/"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Navigation 1" = #"Imported Excel workbook"{[Item = "Nomenklatur", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"N/J", type text}, {"Produktgrupper", type text}, {"Beskrivelse2", type text}, {"Nomenklatur_Tekst", type text}, {"Fagområde", type text}, {"Beskrivelse N", type text}, {"Tilleggskoder", type text}, {"Fastpris", type text}, {"Nomenklatur_Kode", type text}, {"Hovedgruppe", type text}, {"Nomenklatur_Kode2", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Nomenkaltur Mikkel forenklet_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Nomenkaltur Mikkel forenklet" = let
  Source = SharePoint.Files("https://sophiesmindeortopedi.sharepoint.com", [ApiVersion = 15]),
  Navigation = Source{[Name = "dim_nomenklatur.xlsx", #"Folder Path" = "https://sophiesmindeortopedi.sharepoint.com/Shared Documents/PowerBI SMO/"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Navigation 1" = #"Imported Excel workbook"{[Item = "dim_nomenklatur", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"N/J", type text}, {"Nomenklatur_Kode", type text}, {"Produktgrupper", type text}, {"Beskrivelse2", type text}, {"Nomenklatur_Tekst", type text}, {"Fagområde", type text}, {"Beskrivelse N", type text}, {"Tilleggskoder", type text}, {"Fastpris", type text}, {"Konv. Fastpris timer", type text}, {"Hovedgruppe", type text}, {"Nomenklatur_Kode2", type text}})
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Ansatt-Avdeling_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Ansatt-Avdeling" = let
  Source = SharePoint.Files("https://sophiesmindeortopedi.sharepoint.com", [ApiVersion = 15]),
  Navigation = Source{[Name = "dim_employee_mapping.xlsx", #"Folder Path" = "https://sophiesmindeortopedi.sharepoint.com/Shared Documents/PowerBI SMO/"]}[Content],
  #"Imported Excel workbook" = Excel.Workbook(Navigation, null, true),
  #"Navigation 1" = #"Imported Excel workbook"{[Item = "dim_employee_mapping", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Ansattnr", Int64.Type}, {"Ansatt", type text}, {"Avd", type text}, {"Avd2", type text}})
in
  #"Changed column type";
shared Tidskategori_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "0090292d-63b6-403d-b31a-2ae7358fc623"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "e34204fd-d37e-4e43-9b13-c1704b1d2a49"]}[Data],
  Navigation_3 = Navigation_2{[Id = "excel_mappings", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "tidskategori", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Nomenkaltur Mikkel forenklet_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "0090292d-63b6-403d-b31a-2ae7358fc623"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "e34204fd-d37e-4e43-9b13-c1704b1d2a49"]}[Data],
  Navigation_3 = Navigation_2{[Id = "excel_mappings", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "nomenkaltur_mikkel", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Ansatt-Avdeling_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "0090292d-63b6-403d-b31a-2ae7358fc623"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "e34204fd-d37e-4e43-9b13-c1704b1d2a49"]}[Data],
  Navigation_3 = Navigation_2{[Id = "excel_mappings", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Ansatt_avdeling", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Ansatt-Navn_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "0090292d-63b6-403d-b31a-2ae7358fc623"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "e34204fd-d37e-4e43-9b13-c1704b1d2a49"]}[Data],
  Navigation_3 = Navigation_2{[Id = "excel_mappings", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "ansatt_navn", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Nomenklatur_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "0090292d-63b6-403d-b31a-2ae7358fc623"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "e34204fd-d37e-4e43-9b13-c1704b1d2a49"]}[Data],
  Navigation_3 = Navigation_2{[Id = "excel_mappings", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "nomenklatur", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
