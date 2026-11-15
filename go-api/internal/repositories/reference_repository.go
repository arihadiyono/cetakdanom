package repositories

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"cetakdanom/api/internal/models"
)

type ReferenceRepository struct {
	db *sql.DB
}

func NewReferenceRepository(db *sql.DB) *ReferenceRepository {
	return &ReferenceRepository{db: db}
}

// GetProjects returns projects based on Jenis Bansos: NASIONAL, LOKAL, INSTANSI/LEMBAGA
func (r *ReferenceRepository) GetProjects(ctx context.Context, jenis string) ([]models.ProjectRef, error) {
	jenisNorm := strings.ToUpper(strings.TrimSpace(jenis))

	var tableName string
	switch {
	case strings.Contains(jenisNorm, "LOKAL"):
		tableName = "refProject_KOTAKAB"
	case strings.Contains(jenisNorm, "INSTANSI") || strings.Contains(jenisNorm, "LEMBAGA") || strings.Contains(jenisNorm, "INS"):
		tableName = "refProject_INS"
	default: // NASIONAL
		tableName = "refProject_NAS"
	}

	query := fmt.Sprintf(
		"SELECT RTRIM(idproject) AS idproject, RTRIM(Deskripsi) AS Deskripsi FROM %s WHERE Deskripsi IS NOT NULL AND Deskripsi <> '' AND Deskripsi <> '0' ORDER BY Deskripsi",
		tableName,
	)

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("error querying %s: %w", tableName, err)
	}
	defer rows.Close()

	var list []models.ProjectRef
	for rows.Next() {
		var item models.ProjectRef
		if err := rows.Scan(&item.IdProject, &item.Deskripsi); err != nil {
			return nil, fmt.Errorf("error scanning project row: %w", err)
		}
		list = append(list, item)
	}

	return list, nil
}

// GetTahapByProject returns stages based on Jenis Bansos and selected IdProject
func (r *ReferenceRepository) GetTahapByProject(ctx context.Context, jenis, projectId string) ([]models.TahapRef, error) {
	jenisNorm := strings.ToUpper(strings.TrimSpace(jenis))
	projectId = strings.TrimSpace(projectId)

	var tableName string
	switch {
	case strings.Contains(jenisNorm, "LOKAL"):
		tableName = "TTAHAP_KOTAKAB"
	case strings.Contains(jenisNorm, "INSTANSI") || strings.Contains(jenisNorm, "LEMBAGA") || strings.Contains(jenisNorm, "INS"):
		tableName = "TTAHAP_INS"
	default: // NASIONAL
		tableName = "TTAHAP_NAS"
	}

	query := fmt.Sprintf(
		"SELECT RTRIM(id_tahap) AS id_tahap, RTRIM(ket_tahap) AS ket_tahap FROM %s WHERE RTRIM(id_project) = @p1 ORDER BY prioritas, id_tahap",
		tableName,
	)

	rows, err := r.db.QueryContext(ctx, query, sql.Named("p1", projectId))
	if err != nil {
		return nil, fmt.Errorf("error querying %s: %w", tableName, err)
	}
	defer rows.Close()

	var list []models.TahapRef
	for rows.Next() {
		var item models.TahapRef
		if err := rows.Scan(&item.IdTahap, &item.KetTahap); err != nil {
			return nil, fmt.Errorf("error scanning tahap row: %w", err)
		}
		list = append(list, item)
	}

	return list, nil
}

// GetAllKabupaten retrieves all regencies from KABUPATEN1
func (r *ReferenceRepository) GetAllKabupaten(ctx context.Context) ([]models.WilayahKabupaten, error) {
	query := "SELECT RTRIM(KD_KABUPATEN) AS KD_KABUPATEN, RTRIM(KABUPATEN) AS KABUPATEN FROM KABUPATEN1 ORDER BY KABUPATEN"
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("error querying KABUPATEN1: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahKabupaten
	for rows.Next() {
		var item models.WilayahKabupaten
		if err := rows.Scan(&item.Kode, &item.Nama); err != nil {
			return nil, fmt.Errorf("error scanning kabupaten row: %w", err)
		}
		list = append(list, item)
	}

	return list, nil
}

// GetKecamatanByKabupaten retrieves districts from KECAMATAN1 mapped with KD_KABUPATEN
func (r *ReferenceRepository) GetKecamatanByKabupaten(ctx context.Context, kabId string) ([]models.WilayahKecamatan, error) {
	kabId = strings.TrimSpace(kabId)
	query := "SELECT RTRIM(KD_KECAMATAN) AS KD_KECAMATAN, RTRIM(KECAMATAN) AS KECAMATAN, RTRIM(KD_KABUPATEN) AS KD_KABUPATEN FROM KECAMATAN1 WHERE RTRIM(KD_KABUPATEN) = @p1 ORDER BY KECAMATAN"
	rows, err := r.db.QueryContext(ctx, query, sql.Named("p1", kabId))
	if err != nil {
		return nil, fmt.Errorf("error querying KECAMATAN1: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahKecamatan
	for rows.Next() {
		var item models.WilayahKecamatan
		if err := rows.Scan(&item.Kode, &item.Nama, &item.KabupatenId); err != nil {
			return nil, fmt.Errorf("error scanning kecamatan row: %w", err)
		}
		list = append(list, item)
	}

	return list, nil
}

// GetDesaByKecamatan retrieves sub-districts/villages from DESA1 mapped with KD_KECAMATAN (and KD_KABUPATEN)
func (r *ReferenceRepository) GetDesaByKecamatan(ctx context.Context, kecId, kabId string) ([]models.WilayahDesa, error) {
	kecId = strings.TrimSpace(kecId)
	kabId = strings.TrimSpace(kabId)

	var query string
	var args []any

	if kabId != "" {
		query = "SELECT RTRIM(KD_DESA) AS KD_DESA, RTRIM(DESA) AS DESA, RTRIM(KD_KECAMATAN) AS KD_KECAMATAN, RTRIM(KD_KABUPATEN) AS KD_KABUPATEN FROM DESA1 WHERE RTRIM(KD_KECAMATAN) = @p1 AND RTRIM(KD_KABUPATEN) = @p2 ORDER BY DESA"
		args = []any{sql.Named("p1", kecId), sql.Named("p2", kabId)}
	} else {
		query = "SELECT RTRIM(KD_DESA) AS KD_DESA, RTRIM(DESA) AS DESA, RTRIM(KD_KECAMATAN) AS KD_KECAMATAN, RTRIM(KD_KABUPATEN) AS KD_KABUPATEN FROM DESA1 WHERE RTRIM(KD_KECAMATAN) = @p1 ORDER BY DESA"
		args = []any{sql.Named("p1", kecId)}
	}

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("error querying DESA1: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahDesa
	for rows.Next() {
		var item models.WilayahDesa
		if err := rows.Scan(&item.Kode, &item.Nama, &item.KecamatanId, &item.KabupatenId); err != nil {
			return nil, fmt.Errorf("error scanning desa row: %w", err)
		}
		list = append(list, item)
	}

	return list, nil
}

// --------------------------------------------------------------------------
// Backward-compatible methods
// --------------------------------------------------------------------------

func (r *ReferenceRepository) GetLayanan(ctx context.Context) ([]models.LayananBansos, error) {
	projects, err := r.GetProjects(ctx, "NASIONAL")
	if err != nil {
		return nil, err
	}
	var list []models.LayananBansos
	for _, p := range projects {
		list = append(list, models.LayananBansos{
			Kode: p.IdProject,
			Nama: p.Deskripsi,
		})
	}
	return list, nil
}

func (r *ReferenceRepository) GetTahap(ctx context.Context, projectId string) ([]models.TahapBansos, error) {
	tahaps, err := r.GetTahapByProject(ctx, "NASIONAL", projectId)
	if err != nil {
		return nil, err
	}
	var list []models.TahapBansos
	for _, t := range tahaps {
		list = append(list, models.TahapBansos{
			Batch: t.IdTahap,
		})
	}
	return list, nil
}

func (r *ReferenceRepository) GetKabupaten(ctx context.Context, nopend, idPetugas, nippos string) ([]models.WilayahKabupaten, error) {
	return r.GetAllKabupaten(ctx)
}

func (r *ReferenceRepository) GetKecamatan(ctx context.Context, kabId, nopend, idPetugas, nippos string) ([]models.WilayahKecamatan, error) {
	return r.GetKecamatanByKabupaten(ctx, kabId)
}

func (r *ReferenceRepository) GetKelurahan(ctx context.Context, kecId, nopend, idPetugas, nippos string) ([]models.WilayahKelurahan, error) {
	desas, err := r.GetDesaByKecamatan(ctx, kecId, "")
	if err != nil {
		return nil, err
	}
	var list []models.WilayahKelurahan
	for _, d := range desas {
		list = append(list, models.WilayahKelurahan{
			Kode:        d.Kode,
			Nama:        d.Nama,
			KecamatanId: d.KecamatanId,
			KabupatenId: d.KabupatenId,
		})
	}
	return list, nil
}
