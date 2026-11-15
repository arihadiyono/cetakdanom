package repositories

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"cetakdanom/api/internal/models"
)

type DanomRepository struct {
	db *sql.DB
}

func NewDanomRepository(db *sql.DB) *DanomRepository {
	return &DanomRepository{db: db}
}

// GetDanomList executes the appropriate stored procedure based on project/jenis.
// Projects registered in T_REFF_EXTEND_PROJECT (modern projects like PBBA, BD41) use V4 SPs,
// while older projects (like SPK1) use V2 SPs.
func (r *DanomRepository) GetDanomList(
	ctx context.Context,
	kelurahanId string,
	batch string,
	projectId string,
	sort string,
	nopend string,
	idPetugas string,
	nippos string,
	jenis string,
) (*models.DanomListResult, error) {
	if sort == "" {
		sort = "Nama"
	}
	if nopend == "" {
		nopend = "40005"
	}
	if idPetugas == "" {
		idPetugas = "asep"
	}
	if nippos == "" {
		nippos = "000000000"
	}

	spV4 := "SIKAP_GET_DAFTARNOMINATIF_NAS_V4"
	spV2 := "SIKAP_GET_DAFTARNOMINATIF_NAS_V2"
	jenisUpper := strings.ToUpper(strings.TrimSpace(jenis))
	if strings.Contains(jenisUpper, "LOKAL") {
		spV4 = "SIKAP_GET_DAFTARNOMINATIF_KOTAKAB_V4"
		spV2 = "SIKAP_GET_DAFTARNOMINATIF_KOTAKAB_V2"
	} else if strings.Contains(jenisUpper, "INSTANSI") || strings.Contains(jenisUpper, "LEMBAGA") {
		spV4 = "SIKAP_GET_DAFTARNOMINATIF_INSTANSI_V4"
		spV2 = "SIKAP_GET_DAFTARNOMINATIF_INSTANSI_V2"
	}

	// Check whether project exists in T_REFF_EXTEND_PROJECT
	var isExtended int
	_ = r.db.QueryRowContext(ctx, "SELECT CASE WHEN EXISTS (SELECT 1 FROM T_REFF_EXTEND_PROJECT WHERE IDPROJECT = @p1) THEN 1 ELSE 0 END", sql.Named("p1", projectId)).Scan(&isExtended)

	var records []models.DanomRecipient
	var totalNominal float64
	var err error

	if isExtended == 1 {
		// Project is configured with modern extended features (logos, custom footer)
		records, totalNominal, err = r.executeDanomSp(ctx, spV4, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos)
		// Fallback to V2 if V4 produced 0 rows or error
		if err != nil || len(records) == 0 {
			recV2, totV2, errV2 := r.executeDanomSp(ctx, spV2, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos)
			if errV2 == nil && len(recV2) > 0 {
				records = recV2
				totalNominal = totV2
			}
		}
	} else {
		// Legacy project without T_REFF_EXTEND_PROJECT entry (e.g. SPK1)
		records, totalNominal, err = r.executeDanomSp(ctx, spV2, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos)
		// Fallback to V4 if V2 produced 0 rows or error
		if err != nil || len(records) == 0 {
			recV4, totV4, errV4 := r.executeDanomSp(ctx, spV4, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos)
			if errV4 == nil && len(recV4) > 0 {
				records = recV4
				totalNominal = totV4
			}
		}
	}

	if records == nil {
		records = make([]models.DanomRecipient, 0)
	}

	return &models.DanomListResult{
		Records:      records,
		TotalKpm:     len(records),
		TotalNominal: totalNominal,
	}, nil
}

func (r *DanomRepository) executeDanomSp(
	ctx context.Context,
	spName string,
	kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos string,
) ([]models.DanomRecipient, float64, error) {
	query := fmt.Sprintf(`EXEC %s 
		@IDKELURAHAN=@p1, 
		@NOPEND=@p2, 
		@ID_PETUGAS=@p3, 
		@NIPPOS=@p4, 
		@OPT=@p5, 
		@BATCH=@p6, 
		@SORT=@p7, 
		@ID_PROJECT=@p8`, spName)

	rows, err := r.db.QueryContext(ctx, query,
		sql.Named("p1", kelurahanId),
		sql.Named("p2", nopend),
		sql.Named("p3", idPetugas),
		sql.Named("p4", nippos),
		sql.Named("p5", "0"),
		sql.Named("p6", batch),
		sql.Named("p7", sort),
		sql.Named("p8", projectId),
	)
	if err != nil {
		return nil, 0, fmt.Errorf("error executing %s: %w", spName, err)
	}
	defer rows.Close()

	cols, err := rows.Columns()
	if err != nil {
		return nil, 0, err
	}

	records := make([]models.DanomRecipient, 0)
	var totalNominal float64
	isV4 := len(cols) >= 36

	for rows.Next() {
		var (
			idPelanggan, pelanggan, alamat, alamatKtp sql.NullString
			amount                                    sql.NullInt64
			kuantitas                                 sql.NullInt32
			total                                     sql.NullInt64
			idKel, kel, idKec, kec, idKab, kab        sql.NullString
			idProp, prop, idKprk, kprk, idKantor, kpc sql.NullString
			rowBatch, regional, nik                   sql.NullString
			bs1, bs2, msbayar, bs3                    sql.NullString
			statusGaruda, labelTahap                  sql.NullString
			logoDanom, logoPerusahaan, headerDanom    sql.NullString
			footer                                    sql.NullString
			rw, rt, desil, percentile                 sql.NullString
		)

		var scanErr error
		if isV4 {
			scanErr = rows.Scan(
				&idPelanggan, &pelanggan, &alamat, &alamatKtp, &amount, &kuantitas, &total,
				&idKel, &kel, &idKec, &kec, &idKab, &kab,
				&idProp, &prop, &idKprk, &kprk, &idKantor, &kpc,
				&rowBatch, &regional, &nik,
				&bs1, &bs2, &msbayar, &bs3,
				&statusGaruda, &labelTahap,
				&logoDanom, &logoPerusahaan, &headerDanom,
				&footer,
				&rw, &rt, &desil, &percentile,
			)
		} else {
			// V2 column structure (33 columns)
			scanErr = rows.Scan(
				&idPelanggan, &pelanggan, &alamat, &alamatKtp, &amount, &kuantitas, &total,
				&idKel, &kel, &idKec, &kec, &idKab, &kab,
				&idProp, &prop, &idKprk, &kprk, &idKantor, &kpc,
				&rowBatch, &regional, &nik,
				&bs1, &bs2, &msbayar, &bs3,
				&statusGaruda, &labelTahap,
				&headerDanom,
				&rw, &rt, &desil, &percentile,
			)
		}

		if scanErr != nil {
			return nil, 0, fmt.Errorf("error scanning row from %s: %w", spName, scanErr)
		}

		item := models.DanomRecipient{
			IdPelanggan: strings.TrimSpace(idPelanggan.String),
			Nama:        strings.TrimSpace(pelanggan.String),
			Alamat:      strings.TrimSpace(alamat.String),
			AlamatKtp:   strings.TrimSpace(alamatKtp.String),
			Nominal:     float64(amount.Int64),
			Kuantitas:   int(kuantitas.Int32),
			Total:       float64(total.Int64),
			IdKelurahan: strings.TrimSpace(idKel.String),
			Kelurahan:   strings.TrimSpace(kel.String),
			IdKecamatan: strings.TrimSpace(idKec.String),
			Kecamatan:   strings.TrimSpace(kec.String),
			IdKabupaten: strings.TrimSpace(idKab.String),
			Kabupaten:   strings.TrimSpace(kab.String),
			IdProvinsi:  strings.TrimSpace(idProp.String),
			Provinsi:    strings.TrimSpace(prop.String),
			Kprk:        strings.TrimSpace(kprk.String),
			Kantor:      strings.TrimSpace(kpc.String),
			Batch:       strings.TrimSpace(rowBatch.String),
			Regional:    strings.TrimSpace(regional.String),
			Nik:         strings.TrimSpace(nik.String),
			Bs1:         strings.TrimSpace(bs1.String),
			Barcode1:    strings.TrimSpace(bs1.String),
			HeaderDanom: strings.TrimSpace(headerDanom.String),
			Rw:          strings.TrimSpace(rw.String),
			Rt:          strings.TrimSpace(rt.String),
			StatusDanom: "BelumCetak",
		}

		records = append(records, item)
		totalNominal += item.Nominal
	}

	return records, totalNominal, nil
}

// InquiryNik inquiries a recipient by NIK
func (r *DanomRepository) InquiryNik(ctx context.Context, nik string) (*models.CdsRecipientInquiry, error) {
	query := `
		SELECT TOP 1
			ISNULL(id_pelanggan, '') AS id_pelanggan,
			ISNULL(NIK, '') AS NIK,
			ISNULL(NAMA, '') AS NAMA,
			ISNULL(ALAMAT_DTKS, '') AS ALAMAT_DTKS,
			ISNULL(NMDESA_DTKS, '') AS NMDESA_DTKS,
			ISNULL(NMKEC_DTKS, '') AS NMKEC_DTKS,
			ISNULL(NMKAB_DTKS, '') AS NMKAB_DTKS,
			ISNULL(NMPROP_DTKS, '') AS NMPROP_DTKS,
			ISNULL(NOMINAL, 0) AS NOMINAL
		FROM T_PENERIMA_SPK_MBA
		WHERE NIK = @p1
	`

	var (
		idPelanggan, dbNik, nama, alamat sql.NullString
		desa, kec, kab, prop             sql.NullString
		nominal                          sql.NullFloat64
	)

	err := r.db.QueryRowContext(ctx, query, sql.Named("p1", nik)).Scan(
		&idPelanggan, &dbNik, &nama, &alamat,
		&desa, &kec, &kab, &prop,
		&nominal,
	)
	if err == sql.ErrNoRows {
		return nil, nil // not found
	}
	if err != nil {
		return nil, fmt.Errorf("error querying recipient by NIK: %w", err)
	}

	return &models.CdsRecipientInquiry{
		IdResponse:       "000",
		IdPelanggan:      strings.TrimSpace(idPelanggan.String),
		Nik:              strings.TrimSpace(dbNik.String),
		Nama:             strings.TrimSpace(nama.String),
		AlamatDtks:       strings.TrimSpace(alamat.String),
		NmDesaDtks:       strings.TrimSpace(desa.String),
		NmKecDtks:        strings.TrimSpace(kec.String),
		NmKabDtks:        strings.TrimSpace(kab.String),
		NmPropDtks:       strings.TrimSpace(prop.String),
		Nominal:          nominal.Float64,
		NoVoucher:        "VCH-" + strings.TrimSpace(dbNik.String),
		NamaPerusahaan:   "KEMENSOS RI",
		AlamatPerusahaan: "JAKARTA PUSAT",
	}, nil
}
