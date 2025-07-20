# Base de Datos PUBS - Proyecto SQL Server

## 📚 Descripción

Base de datos de sistema editorial que gestiona **autores**, **libros**, **editoriales** y **ventas**.

**Características:**
- 12 tablas principales
- 10 relaciones (FK)

## 🔗 Diagrama Entidad-Relación

```mermaid
erDiagram
    authors {
        varchar au_id PK
        varchar au_lname
        varchar au_fname
        char phone
        varchar address
        varchar city
        char state
        char zip
        bit contract
    }
    
    titles {
        varchar title_id PK
        varchar title
        char type
        char pub_id FK
        money price
        money advance
        int royalty
        int ytd_sales
        varchar notes
        datetime pubdate
    }
    
    publishers {
        char pub_id PK
        varchar pub_name
        varchar city
        char state
        varchar country
    }
    
    titleauthor {
        varchar au_id PK,FK
        varchar title_id PK,FK
        tinyint au_ord
        int royaltyper
    }
    
    stores {
        char stor_id PK
        varchar stor_name
        varchar stor_address
        varchar city
        char state
        char zip
    }
    
    sales {
        char stor_id PK,FK
        varchar ord_num PK
        varchar title_id PK,FK
        datetime ord_date
        smallint qty
        varchar payterms
    }
    
    employee {
        char emp_id PK
        varchar fname
        char minit
        varchar lname
        smallint job_id FK
        tinyint job_lvl
        char pub_id FK
        datetime hire_date
    }
    
    jobs {
        smallint job_id PK
        varchar job_desc
        tinyint min_lvl
        tinyint max_lvl
    }
    
    discounts {
        varchar discounttype
        char stor_id FK
        smallint lowqty
        smallint highqty
        decimal discount
    }
    
    roysched {
        varchar title_id FK
        int lorange
        int hirange
        int royalty
    }
    
    pub_info {
        char pub_id PK,FK
        image logo
        text pr_info
    }

    %% Relaciones principales
    authors ||--o{ titleauthor : "escribe"
    titles ||--o{ titleauthor : "es escrito por"
    titles }o--|| publishers : "publica"
    titles ||--o{ sales : "se vende"
    stores ||--o{ sales : "vende"
    stores ||--o{ discounts : "ofrece"
    publishers ||--o{ employee : "emplea"
    jobs ||--o{ employee : "tiene"
    titles ||--o{ roysched : "genera regalías"
    publishers ||--o| pub_info : "información"
```

## 📊 Entidades Principales

- **📖 titles** - Catálogo de libros y publicaciones
- **✍️ authors** - Escritores y colaboradores  
- **🏢 publishers** - Casas editoras
- **🏪 stores** - Librerías y puntos de venta
- **👥 employee** - Personal de la editorial
- **💰 sales** - Transacciones de venta
- **🏷️ discounts** - Descuentos por tienda
- **💸 roysched** - Esquemas de regalías
- **ℹ️ pub_info** - Información detallada de editoriales
- **💼 jobs** - Cargos y puestos de trabajo

## 🔗 Relaciones Clave

**N:M** - Autores ↔ Libros (tabla: `titleauthor`)  
**1:N** - Editorial → Empleados  
**1:N** - Editorial → Libros  
**1:N** - Librería → Ventas  
**1:N** - Librería → Descuentos  
**1:N** - Libros → Regalías  
**1:1** - Editorial → Información detallada  

## 📁 Estructura del Proyecto

```
DatabaseProjectPubs/
DatabaseProjectPubs/
├── README.md
├── BDPubs
│   ├── BDPubsOLTP
│   │   └── Schema
│   │       ├── StoredProcedures
│   │       │   ├── byroyalty.sql
│   │       │   ├── GetDatabaseRowVersion.sql
│   │       │   ├── GetSalesChangeByRowVersion.sql
│   │       │   ├── GetStoresChangeByRowVersion.sql
│   │       │   ├── GetTitleChangeByRowVersion.sql
│   │       │   ├── reptq1.sql
│   │       │   ├── reptq2.sql
│   │       │   └── reptq3.sql
│   │       ├── Tables
│   │       │   ├── authors.sql
│   │       │   ├── discounts.sql
│   │       │   ├── employee.sql
│   │       │   ├── jobs.sql
│   │       │   ├── pub_info.sql
│   │       │   ├── publishers.sql
│   │       │   ├── roysched.sql
│   │       │   ├── sales.sql
│   │       │   ├── stores.sql
│   │       │   ├── titleauthor.sql
│   │       │   └── titles.sql
│   │       ├── UserDefinedTypes
│   │       │   ├── empid.sql
│   │       │   ├── id.sql
│   │       │   └── tid.sql
│   │       └── Views
│   │           └── titleview.sql
│   └── BDPubsDW
│       └── Schema
│           ├── Tables
│           │   ├── DimAuthor.sql
│           │   ├── DimDate.sql
│           │   ├── DimStore.sql
│           │   ├── DimTitle.sql
│           │   └── FactSales.sql
```


# Modelo Estrella - Pubs Data Warehouse

Este es el modelo estrella basado en las tablas `DimAuthor`, `DimDate`, `DimStore`, `DimTitle` y la tabla de hechos `FactSales`.

## Diagrama ER (Mermaid)

```mermaid

erDiagram
    DimAuthor {
        int AuthorKey PK
        varchar au_id_original
        varchar title_id_original
        varchar au_fname
        varchar au_lname
        varchar author_full_name
        char phone
        varchar address
        varchar city
        char state
        char zip
        bit contract
        tinyint au_ord
        int royaltyper
        varchar title
        char title_type
        datetime2 RowInsertedDate
        datetime2 RowUpdatedDate
        bit IsCurrentRecord
    }

    DimDate {
        int DateKey PK
        date FullDate
        int Year
        int Quarter
        int Month
        int Day
        varchar MonthName
        char MonthNameShort
        varchar DayName
        char DayNameShort
        int DayOfYear
        int WeekOfYear
        int DayOfWeek
        bit IsWeekend
        bit IsHoliday
        varchar HolidayName
        varchar QuarterName
        int SemesterNumber
        varchar SemesterName
        varchar DateFormatted
        varchar MonthYear
        varchar YearMonth
    }

    DimStore {
        int StoreKey PK
        char stor_id_original
        varchar stor_name
        varchar stor_address
        varchar city
        char state
        char zip
        datetime2 RowInsertedDate
        datetime2 RowUpdatedDate
        bit IsCurrentRecord
    }

    DimTitle {
        int TitleKey PK
        varchar title_id_original
        varchar title
        char type
        money price
        money advance
        int royalty
        int ytd_sales
        varchar notes
        datetime pubdate
        char pub_id_original
        varchar publisher_name
        varchar publisher_city
        char publisher_state
        varchar publisher_country
        datetime2 RowInsertedDate
        datetime2 RowUpdatedDate
        bit IsCurrentRecord
    }

    FactSales {
        int SalesKey PK
        int StoreKey FK
        int TitleKey FK
        int AuthorKey FK
        int OrderDateKey FK
        char stor_id_original
        varchar title_id_original
        varchar ord_num_original
        smallint Quantity
        money UnitPrice
        money TotalAmount
        decimal DiscountPercent
        money DiscountAmount
        money NetAmount
        varchar PayTerms
        datetime OrderDate
        datetime2 RowInsertedDate
        datetime2 RowUpdatedDate
        int ETL_BatchID
    }

    %% Relaciones principales
    DimAuthor ||--o{ FactSales : "AuthorKey"
    DimDate ||--o{ FactSales : "OrderDateKey"
    DimStore ||--o{ FactSales : "StoreKey"
    DimTitle ||--o{ FactSales : "TitleKey"

```