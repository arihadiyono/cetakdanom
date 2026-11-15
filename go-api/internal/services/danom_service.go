package services

import (
	"context"
	"strings"

	"cetakdanom/api/internal/models"
	"cetakdanom/api/internal/repositories"
)

type DanomService struct {
	repo *repositories.DanomRepository
}

func NewDanomService(repo *repositories.DanomRepository) *DanomService {
	return &DanomService{repo: repo}
}

func (s *DanomService) GetDanomList(
	ctx context.Context,
	kelurahanId string,
	batch string,
	projectId string,
	sort string,
	nopend string,
	idPetugas string,
	nippos string,
	searchQuery string,
	page int,
	pageSize int,
) (*models.DanomListResult, *models.Pagination, error) {
	result, err := s.repo.GetDanomList(ctx, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos)
	if err != nil {
		return nil, nil, err
	}

	filtered := result.Records
	if searchQuery != "" {
		q := strings.ToUpper(strings.TrimSpace(searchQuery))
		var matched []models.DanomRecipient
		var totalNom float64
		for _, r := range filtered {
			if strings.Contains(strings.ToUpper(r.Nama), q) || strings.Contains(r.Nik, q) || strings.Contains(strings.ToUpper(r.Alamat), q) {
				matched = append(matched, r)
				totalNom += r.Nominal
			}
		}
		filtered = matched
		result.TotalKpm = len(matched)
		result.TotalNominal = totalNom
	}

	totalRecords := len(filtered)
	var paginatedRecords []models.DanomRecipient
	var pagination *models.Pagination

	if pageSize > 0 && page > 0 {
		totalPages := (totalRecords + pageSize - 1) / pageSize
		start := (page - 1) * pageSize
		if start > totalRecords {
			start = totalRecords
		}
		end := start + pageSize
		if end > totalRecords {
			end = totalRecords
		}
		paginatedRecords = filtered[start:end]
		pagination = &models.Pagination{
			Page:         page,
			PageSize:     pageSize,
			TotalRecords: totalRecords,
			TotalPages:   totalPages,
		}
	} else {
		paginatedRecords = filtered
		pagination = &models.Pagination{
			Page:         1,
			PageSize:     totalRecords,
			TotalRecords: totalRecords,
			TotalPages:   1,
		}
	}

	result.Records = paginatedRecords
	return result, pagination, nil
}

func (s *DanomService) InquiryNik(ctx context.Context, nik string) (*models.CdsRecipientInquiry, error) {
	return s.repo.InquiryNik(ctx, nik)
}
